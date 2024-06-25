class User < ApplicationRecord
  scanning column_name: "role", change_user_column: "id"

  enum :role, { normal: 0, admin: 1 }
end
