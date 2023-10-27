# frozen_string_literal: true

module Snapcher
  module Junker
    extend ActiveSupport::Concern

    CALLBACKS = %i[scanning_create scanning_update scanning_destroy]

    module ClassMethods
      def scanning(options = {})
        extend Snapcher::Junker::SnapcherClassMethods
        include Snapcher::Junker::ScanningInstanceMethods

        class_attribute :snapcher_options, instance_writer: false

        self.snapcher_options = options

        has_many :scannings, lambda {
                               order(version: :asc)
                             }, as: :scannable, class_name: "Snapcher::Scanning", inverse_of: :scannable

        after_create :scanning_create
        before_update :scanning_update
        before_destroy :scanning_destroy

        define_callbacks :scanning
      end
    end

    module ScanningInstanceMethods
      def scanning_create
        run_scanning(action: "create",
                     column_name: snapcher_options[:column_name],
                     after_params: snapcher_attributes[snapcher_options[:column_name]],
                     table_name: self.class.table_name)
      end

      def scanning_update
        return unless (changes = snapcher_changes).present?

        run_scanning(action: "update",
                     column_name: snapcher_options[:column_name],
                     table_name: self.class.table_name,
                     before_params: snapcher_changes[:before_params],
                     after_params: snapcher_changes[:after_params])
      end

      def scanning_destroy
        return if new_record?

        run_scanning(action: "destroy", column_name: snapcher_options[:column_name],
                     table_name: self.class.table_name)
      end

      # List of attributes that are snapcher.
      def snapcher_attributes
        snapcher_attributes = filter_encrypted_attrs(attributes)
        normalize_enum_changes(snapcher_attributes)
      end

      def scanning_change_values
        all_changes = if respond_to?(:changes_to_save)
                        changes_to_save
                      else
                        changes
                      end

        filtered_changes = filter_encrypted_attrs(all_changes)
        filtered_changes = normalize_enum_changes(filtered_changes)
        filtered_changes.to_hash
      end

      def snapcher_changes
        filtered_changes = scanning_change_values

        monitoring_column_name = snapcher_options[:column_name]

        return if filtered_changes[monitoring_column_name.to_s].nil?

        before_params = filtered_changes[monitoring_column_name.to_s][0]
        after_params = filtered_changes[monitoring_column_name.to_s][1]
        { before_params:, after_params: }
      end

      def run_scanning(attrs)
        run_callbacks(:scanning) do
          scanning = scannings.create(attrs)
          scanning
        end
      end

      def filter_encrypted_attrs(filtered_changes)
        filter_attr_values(
          snapcher_changes: filtered_changes,
          attrs: respond_to?(:encrypted_attributes) ? Array(encrypted_attributes).map(&:to_s) : []
        )
      end

      def filter_attr_values(snapcher_changes: {}, attrs: [], placeholder: "[FILTERED]")
        attrs.each do |attr|
          next unless snapcher_changes.key?(attr)

          changes = snapcher_changes[attr]
          values = changes.is_a?(Array) ? changes.map { placeholder } : placeholder

          snapcher_changes[attr] = values
        end

        snapcher_changes
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
      def snapcher_columns
        @snapcher_columns ||= column_names
      end
    end
  end
end
