class TrackingLogs < ActiveRecord::Migration
  def self.up
    create_table :tracking_logs do |t|
      t.column :id, :primary_key
      t.column :log_id, :integer
      t.column :tracker, :string
      t.column :title, :string
      t.column :link, :string
      t.column :date, :datetime
      t.column :status, :string
      t.column :content, :string
    end
    add_index :tracking_logs, [:title, :link], :unique => true, :name => 'trac_log_title'
  end

  def self.down
    drop_table :tracking_logs
  end
end
