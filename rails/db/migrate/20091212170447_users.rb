class Users < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      # user information
      t.column :id,                        :primary_key
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :apikey,                    :string
      t.column :accesskey,                 :string
      t.column :page_in_item,              :integer
      # user authority
      t.column :profile_in_item,           :boolean
      t.column :qrcode_in_item,            :boolean
      t.column :category_count_in_item,    :boolean
      t.column :total_cost_in_item,        :boolean
      t.column :calendar_in_item,          :boolean
      t.column :page_in_wish,              :integer
      t.column :category_count_in_wish,    :boolean
      t.column :calendar_in_wish,          :boolean
    end
    add_index :users, :apikey, :unique => true, :name => 'apikey_index'
  end

  def self.down
    drop_table :users
  end
end
