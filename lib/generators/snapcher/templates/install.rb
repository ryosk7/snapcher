# frozen_string_literal: true

class <%= migration_class_name %> < <%= migration_parent %>
  def self.up
    create_table :snapchers, :force => true do |t|
      t.column :table_name, :string
      t.column :column_name, :string
      t.column :before_params, :string
      t.column :after_params, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :snapchers
  end
end
