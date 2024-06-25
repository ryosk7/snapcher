class CreateGifts < ActiveRecord::Migration[7.1]
  def change
    create_table :gifts do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.string :name

      t.timestamps
    end
  end
end
