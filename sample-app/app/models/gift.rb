class Gift < ApplicationRecord
  scanning column_name: "name", change_user_column: "from_user_id"
end
