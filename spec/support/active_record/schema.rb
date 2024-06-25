require "active_record"

begin
  db_config = ActiveRecord::Base.configurations[Rails.env].clone
  db_type = db_config["adapter"]
  db_name = db_config.delete("database")
  raise StandardError, "No database name specified." if db_name.blank?
  raise StandardError, "Not yet supported." if db_type != "sqlite3"

  db_file = Pathname.new(__FILE__).dirname.join(db_name)
  db_file.unlink if db_file.file?
rescue StandardError => e
  Kernel.warn e
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.column :name, :string
    t.column :role, :integer, default: 0
    t.column :bio, :text
    t.column :rate, :float
    t.column :birthday, :datetime
    t.column :last_action_time, :timestamp
    t.column :bot, :boolean
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  create_table :scannings do |t|
    t.column :scannable_id, :integer
    t.column :scannable_type, :string
    t.column :table_name, :string
    t.column :column_name, :string
    t.column :before_params, :string
    t.column :after_params, :string
    t.column :action, :string
    t.column :user_id, :integer
    t.column :created_at, :datetime
  end

  create_table :orders do |t|
    t.column :scan_user_id, :string
    t.column :navigate_user_id, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

end
