require "rails/generators"
require "rails/generators/migration"
require "active_record"
require "rails/generators/active_record"

module Snapcher
  class InstallGenerator < ::Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("../../templates", __FILE__)

    def copy_migration
      migration_template "install.rb", "db/migrate/install_snapcher.rb"
    end

    # Implement the required interface for Rails::Generators::Migration.
    def self.next_migration_number(dirname) # :nodoc:
      next_migration_number = current_migration_number(dirname) + 1
      if timestamped_migrations?
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
      else
        "%.3d" % next_migration_number
      end
    end

    def self.timestamped_migrations?
      (Rails.version >= "7.0") ?
        ::ActiveRecord.timestamped_migrations :
        ::ActiveRecord::Base.timestamped_migrations
    end

    def migration_parent
      "ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]"
    end
  end
end
