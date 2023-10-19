class User < ApplicationRecord
  scanning column_name: "role"

  enum :role, { normal: 0, admin: 1 }
end
