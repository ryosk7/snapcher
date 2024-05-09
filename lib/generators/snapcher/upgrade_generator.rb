# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"
require "active_record"
require "rails/generators/active_record"
require "generators/snapcher/migration"
require "generators/snapcher/migration_helper"

module Snapcher
  module Generators
    class UpgradeGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      include Snapcher::Generators::MigrationHelper
      extend Snapcher::Generators::Migration

      class_option :snapcher_user_id_column_type, type: :string, default: "integer", required: false

      source_root File.expand_path("../templates", __FILE__)

      def copy_templates
        migration_template "add_user_id_to_scannings.rb", "db/migrate/add_user_id_to_scannings.rb"
      end
    end
  end
end
