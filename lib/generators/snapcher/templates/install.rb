# frozen_string_literal: true

class <%= migration_class_name %> < <%= migration_parent %>
  def self.up
    create_table :scannings, :force => true do |t|
      t.column :scannable_id, :integer
      t.column :scannable_type, :string
      t.column :table_name, :string
      t.column :column_name, :string
      t.column :before_params, :string
      t.column :after_params, :string
      t.column :action, :string
      t.column :created_at, :datetime
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :scannings
  end
end
