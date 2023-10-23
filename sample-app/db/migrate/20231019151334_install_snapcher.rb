# frozen_string_literal: true

class InstallSnapcher < ActiveRecord::Migration[7.1]
  def self.up
    create_table :scannings, force: true do |t|
      t.column :scannable_id, :integer
      t.column :scannable_type, :string
      t.column :table_name, :string
      t.column :column_name, :string
      t.column :before_params, :string
      t.column :after_params, :string
      t.column :action, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :scannings
  end
end
