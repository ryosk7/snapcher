require File.expand_path("schema", __dir__)

module Models
  module ActiveRecord
    class User < ::ActiveRecord::Base
      scanning column_name: "role"

      enum :role, { snatcher: 0, navigator: 1, juncker: 2, hunter: 3 }

      def name
        write_attribute(:name)
      end
    end

    class Order < ::ActiveRecord::Base
      scanning column_name: "scan_user_id", snatch_user: "navigate_user_id"
    end
  end
end
