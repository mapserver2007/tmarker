class DevelopmentLogs < ActiveRecord::Migration
  def self.up
    create_table :development_logs do |t|
      t.column :id, :primary_key
      t.column :log_id, :integer
      t.column :title, :string
      t.column :link, :string
      t.column :date, :datetime
    end
    add_index :development_logs, [:title, :link], :unique => true, :name => 'dev_log_title_link_index'
  end

  def self.down
    drop_table :development_logs
  end
end
