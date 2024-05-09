# frozen_string_literal: true

class <%= migration_class_name %> < <%= migration_parent %>
  def self.up
    add_column :scannings, :user_id, :<%= options[:snapcher_user_id_column_type] %>, after: :action

    add_index :scannings, [:user_id], name: index_name
  end

  def self.down
    remove_column :scannings, :user_id
    remove_index :scannings, name: index_name
  end

  private

  def index_name
    'snapcher_user_index'
  end
end
