# frozen_string_literal: true

class AddUserIdToScannings < ActiveRecord::Migration[7.1]
  def self.up
    add_column :scannings, :user_id, :integer

    add_index :scannings, [:user_id], name: index_name
  end

  def self.down
    remove_column :scannings, :user_id
    remove_index :scannings, name: index_name
  end

  private

  def index_name
    'user_index'
  end
end
