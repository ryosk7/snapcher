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
      end
    end

    module SnapshotInstanceMethods
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
        audited_attributes = filter_encrypted_attrs(attributes)
        normalize_enum_changes(audited_attributes)
      end

      def snapshot_change_values
        all_changes = if respond_to?(:changes_to_save)
          changes_to_save
        else
          changes
        end

        filtered_changes = filter_encrypted_attrs(all_changes)
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
        self.class.defined_enums.each do |name, values|
          next unless changes.key?(name)

          changes[name] = \
            if changes[name].is_a?(Array)
              changes[name].map { |v| values[v] }
            else
              values[changes[name]]
            end
        end
        changes
      end

      CALLBACKS.each do |attr_name|
        alias_method "#{attr_name}_callback".to_sym, attr_name
      end
    end

    module SnapcherClassMethods
      def audited_columns
        @audited_columns ||= column_names
      end
    end
  end
end
