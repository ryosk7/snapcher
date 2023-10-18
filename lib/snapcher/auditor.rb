# frozen_string_literal: true
require 'debug'

module Snapcher
  module Auditor
    extend ActiveSupport::Concern

    CALLBACKS = [:snapshot_create]

    module ClassMethods
      def snapshot
        extend Snapcher::Auditor::SnapcherClassMethods
        include Snapcher::Auditor::SnapshotInstanceMethods

        class_attribute :audited_options, instance_writer: false

        has_many :snapchers, -> { order(version: :asc) }, as: :snapchable, class_name: "Snapcher::Snapshot", inverse_of: :snapchable

        after_create :snapshot_create

        define_callbacks :snapshot
        # set_callback :snapshot, :after, :after_snapshot
        # set_callback :snapshot, :around, :around_snapshot
      end
    end

    module SnapshotInstanceMethods
      def snapshot_create
        write_audit(action: "create", audited_changes: audited_attributes)
      end

      # List of attributes that are audited.
      def audited_attributes
        audited_attributes = attributes.except(*self.class.non_audited_columns)
        audited_attributes = redact_values(audited_attributes)
        audited_attributes = filter_encrypted_attrs(audited_attributes)
        normalize_enum_changes(audited_attributes)
      end

      def write_audit
        run_callbacks(:snapshot) {
          p "========== snapshot callback =========="
          snapshot = snapchers.create(attrs)
          snapshot
        }
      end

      def redact_values(filtered_changes)
        debugger
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
