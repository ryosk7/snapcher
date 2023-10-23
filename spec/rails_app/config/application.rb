require "active_record/railtie"

module RailsApp
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.i18n.enforce_available_locales = true

    config.active_record.yaml_column_permitted_classes = [
      String,
      Symbol,
      Integer,
      NilClass,
      Float,
      Time,
      Date,
      FalseClass,
      Hash,
      Array,
      DateTime,
      TrueClass,
      BigDecimal,
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      ActiveSupport::HashWithIndifferentAccess
    ]

    config.active_support.cache_format_version = 7.0
  end
end

require "active_record/connection_adapters/sqlite3_adapter"
if ActiveRecord::ConnectionAdapters::SQLite3Adapter.respond_to?(:represent_boolean_as_integer)
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer = true
end
