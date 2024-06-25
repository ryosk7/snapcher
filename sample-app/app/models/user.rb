class User < ApplicationRecord
  scanning column_name: "role", snatch_user: "id"

  enum :role, { normal: 0, admin: 1 }
end
