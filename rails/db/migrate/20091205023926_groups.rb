class Groups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :id, :primary_key
      t.column :product_group, :string
      t.column :product_name, :string
      t.column :product_icon, :string
    end
  end

  def self.down
    drop_table :groups
  end
end
