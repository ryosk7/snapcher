require File.expand_path("../schema", __FILE__)

module Models
  module ActiveRecord
    class User < ::ActiveRecord::Base
      scanning column_name: "role"

      enum :role, { normal: 0, admin: 1 }
    end
  end
end
