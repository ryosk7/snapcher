# frozen_string_literal: true
require 'debug'

module Snapcher
  module Auditor
    extend ActiveSupport::Concern

    CALLBACKS = [:snapshot_create, :snapshot_update, :snapshot_destroy]

    module ClassMethods
      def snapshot(options = {})
        extend Snapcher::Auditor::SnapcherClassMethods
        include Snapcher::Auditor::SnapshotInstanceMethods

        class_attribute :audited_options, instance_writer: false

        self.audited_options = options

        has_many :snapchers, -> { order(version: :asc) }, as: :snapshotable, class_name: "Snapcher::Snapshot", inverse_of: :snapshotable

        after_create :snapshot_create
        before_update :snapshot_update
        before_destroy :snapshot_destroy

        define_callbacks :snapshot
        # set_callback :snapshot, :after, :after_snapshot
        # set_callback :snapshot, :around, :around_snapshot
      end
    end

    module SnapshotInstanceMethods
      REDACTED = "[REDACTED]"

      def snapshot_create
        write_audit(action: "create", column_name: self.audited_options[:monitoring_column_name], after_params: audited_attributes[self.audited_options[:monitoring_column_name]], table_name: self.class.table_name)
      end

      def snapshot_update
        if (changes = audited_changes).present?
          write_audit(action: "update", column_name: self.audited_options[:monitoring_column_name], table_name: self.class.table_name, before_params: audited_changes[:before_params], after_params: audited_changes[:after_params])
        end
      end

      def snapshot_destroy
        unless new_record?
          write_audit(action: "destroy", column_name: self.audited_options[:monitoring_column_name], table_name: self.class.table_name)
        end
      end

      # List of attributes that are audited.
      def audited_attributes
        audited_attributes = attributes.except(*self.class.non_audited_columns)
        audited_attributes = redact_values(audited_attributes)
        audited_attributes = filter_encrypted_attrs(audited_attributes)
        normalize_enum_changes(audited_attributes)
      end

      def snapshot_change_values
        all_changes = if respond_to?(:changes_to_save)
          changes_to_save
        else
          changes
        end

        filtered_changes = \
          if audited_options[:only].present?
            all_changes.slice(*self.class.audited_columns)
          else
            all_changes.except(*self.class.non_audited_columns)
          end

        filtered_changes = redact_values(filtered_changes)
        filtered_changes = filter_encrypted_attrs(filtered_changes)
        filtered_changes = normalize_enum_changes(filtered_changes)
        filtered_changes.to_hash
      end

      def audited_changes
        filtered_changes = snapshot_change_values

        monitoring_column_name = self.audited_options[:monitoring_column_name]

        return if filtered_changes[monitoring_column_name.to_s].nil?

        before_params = filtered_changes[monitoring_column_name.to_s][0]
        after_params = filtered_changes[monitoring_column_name.to_s][1]
        {before_params: before_params, after_params: after_params}
      end

      def write_audit(attrs)
        run_callbacks(:snapshot) {
          snapshot = snapchers.create(attrs)
          snapshot
        }
      end

      def filter_encrypted_attrs(filtered_changes)
        filter_attr_values(
          audited_changes: filtered_changes,
          attrs: respond_to?(:encrypted_attributes) ? Array(encrypted_attributes).map(&:to_s) : []
        )
      end

      def filter_attr_values(audited_changes: {}, attrs: [], placeholder: "[FILTERED]")
        attrs.each do |attr|
          next unless audited_changes.key?(attr)

          changes = audited_changes[attr]
          values = changes.is_a?(Array) ? changes.map { placeholder } : placeholder

          audited_changes[attr] = values
        end

        audited_changes
      end

      def normalize_enum_changes(changes)
        return changes if Snapcher.store_synthesized_enums

        self.class.defined_enums.each do |name, values|
          if changes.has_key?(name)
            changes[name] = \
              if changes[name].is_a?(Array)
                changes[name].map { |v| values[v] }
              elsif rails_below?("5.0")
                changes[name]
              else
                values[changes[name]]
              end
          end
        end
        changes
      end

      def redact_values(filtered_changes)
        filter_attr_values(
          audited_changes: filtered_changes,
          attrs: Array(audited_options[:redacted]).map(&:to_s),
          placeholder: audited_options[:redaction_value] || REDACTED
        )
      end

      CALLBACKS.each do |attr_name|
        alias_method "#{attr_name}_callback".to_sym, attr_name
      end
    end

    module SnapcherClassMethods
      def default_ignored_attributes
        [primary_key, inheritance_column] | Snapcher.ignored_attributes
      end

      def audited_columns
        @audited_columns ||= column_names - non_audited_columns
      end

      # We have to calculate this here since column_names may not be available when `audited` is called
      def non_audited_columns
        @non_audited_columns ||= calculate_non_audited_columns
      end

      def non_audited_columns=(columns)
        @audited_columns = nil # reset cached audited columns on assignment
        @non_audited_columns = columns.map(&:to_s)
      end

      def calculate_non_audited_columns
        default_ignored_attributes
      end
    end
  end
end
