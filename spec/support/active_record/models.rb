require File.expand_path("schema", __dir__)

module Models
  module ActiveRecord
    class User < ::ActiveRecord::Base
      scanning column_name: "role"

      enum :role, { normal: 0, admin: 1 }

      def name
        write_attribute(:name)
      end
    end
  end
end
