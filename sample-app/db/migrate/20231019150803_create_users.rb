class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :phone
      t.text :bio
      t.float :rate
      t.datetime :birthday
      t.timestamp :last_action_time
      t.boolean :bot

      t.timestamps
    end
  end
end
