class Post < ApplicationRecord
  scanning column_name: "title"

  belongs_to :user
end
