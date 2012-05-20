class Accesses < ActiveRecord::Migration
  def self.up
    create_table :accesses do |t|
      t.column :id,              :primary_key
      t.column :user_id,         :integer
      t.column :allow_id,        :integer
      t.column :allow_url,       :text
      t.column :allow_host,      :string
      t.column :allow_ipaddr,    :string
    end
    add_index :accesses, [:user_id, :allow_id], :unique => true,
      :name => 'accesses_multiple_key'
  end

  def self.down
    drop_table :accesses
  end
end
