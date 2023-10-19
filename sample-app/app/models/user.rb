class User < ApplicationRecord
  snapshot monitoring_column_name: "role"

  enum :role, { normal: 0, admin: 1 }
end
