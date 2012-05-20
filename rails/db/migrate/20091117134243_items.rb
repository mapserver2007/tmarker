class Items < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column :id,                :primary_key
      t.column :user_id,           :integer
      t.column :group_id,          :integer
      t.column :register_date,     :datetime
      t.column :item_title,        :string
      t.column :item_price,        :integer
      t.column :author,            :string
      t.column :creator,           :string
      t.column :publisher,         :string
      t.column :isbn,              :string
      t.column :jancode,           :string
      t.column :release_date,      :datetime
      t.column :publication_date,  :datetime
      t.column :open,              :boolean
      t.column :item_count,        :integer, :default => 1
      t.column :item_image_small,  :string
      t.column :item_image_medium, :string
      t.column :item_image_large,  :string
      t.column :item_link,         :text
    end
    add_index :items, [:user_id, :jancode], :unique => true, :name => 'item_user_jancode'
    add_index :items, :item_title, :name => 'item_title_index'
    add_index :items, :item_price, :name => 'item_price_index'
    add_index :items, :author, :name => 'author_index'
    add_index :items, :publisher, :name => 'publisher_index'
  end

  def self.down
    drop_table :items
  end
end
