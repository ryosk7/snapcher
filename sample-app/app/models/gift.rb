class Gift < ApplicationRecord
  scanning column_name: "to_user_id", change_user_column: "from_user_id"
end
