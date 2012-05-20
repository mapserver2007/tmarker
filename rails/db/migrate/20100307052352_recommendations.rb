class Recommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.column :id, :primary_key
      t.column :item_id, :string
      t.column :item_title, :string
      t.column :item_image_small, :string
      t.column :item_link, :text
      t.column :jancode, :string
      t.column :release_date, :datetime
    end
    add_index :recommendations, [:item_id, :item_title], :unique => true, :name => 'rec_id_title'
    add_index :recommendations, :item_id, :name => 'rec_item_id_index'
  end

  def self.down
    drop_table :recommendations
  end
end
