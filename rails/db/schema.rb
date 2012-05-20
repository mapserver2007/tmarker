# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100516041121) do

  create_table "accesses", :force => true do |t|
    t.integer "user_id"
    t.integer "allow_id"
    t.text    "allow_url"
    t.string  "allow_host"
    t.string  "allow_ipaddr"
  end

  add_index "accesses", ["user_id", "allow_id"], :name => "accesses_multiple_key", :unique => true

  create_table "development_logs", :force => true do |t|
    t.integer  "log_id"
    t.string   "title"
    t.string   "link"
    t.datetime "date"
  end

  add_index "development_logs", ["title", "link"], :name => "dev_log_title_link_index", :unique => true

  create_table "groups", :force => true do |t|
    t.string "product_group"
    t.string "product_name"
    t.string "product_icon"
  end

  create_table "items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "register_date"
    t.string   "item_title"
    t.integer  "item_price"
    t.string   "author"
    t.string   "creator"
    t.string   "publisher"
    t.string   "isbn"
    t.string   "jancode"
    t.datetime "release_date"
    t.datetime "publication_date"
    t.boolean  "open"
    t.integer  "item_count",        :default => 1
    t.string   "item_image_small"
    t.string   "item_image_medium"
    t.string   "item_image_large"
    t.text     "item_link"
  end

  add_index "items", ["author"], :name => "author_index"
  add_index "items", ["item_price"], :name => "item_price_index"
  add_index "items", ["item_title"], :name => "item_title_index"
  add_index "items", ["publisher"], :name => "publisher_index"
  add_index "items", ["user_id", "jancode"], :name => "item_user_jancode", :unique => true

  create_table "recommendations", :force => true do |t|
    t.string   "item_id"
    t.string   "item_title"
    t.string   "item_image_small"
    t.text     "item_link"
    t.string   "jancode"
    t.datetime "release_date"
  end

  add_index "recommendations", ["item_id", "item_title"], :name => "rec_id_title", :unique => true
  add_index "recommendations", ["item_id"], :name => "rec_item_id_index"

  create_table "tracking_logs", :force => true do |t|
    t.integer  "log_id"
    t.string   "tracker"
    t.string   "title"
    t.string   "link"
    t.datetime "date"
    t.string   "status"
    t.string   "content"
  end

  add_index "tracking_logs", ["title", "link"], :name => "trac_log_title", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "apikey"
    t.string   "accesskey"
    t.integer  "page_in_item"
    t.boolean  "profile_in_item"
    t.boolean  "qrcode_in_item"
    t.boolean  "category_count_in_item"
    t.boolean  "total_cost_in_item"
    t.boolean  "calendar_in_item"
    t.integer  "page_in_wish"
    t.boolean  "category_count_in_wish"
    t.boolean  "calendar_in_wish"
  end

  add_index "users", ["apikey"], :name => "apikey_index", :unique => true

  create_table "wishes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "register_date"
    t.string   "item_title"
    t.integer  "item_price"
    t.string   "author"
    t.string   "creator"
    t.string   "publisher"
    t.string   "isbn"
    t.string   "jancode"
    t.datetime "release_date"
    t.datetime "publication_date"
    t.string   "item_image_small"
    t.string   "item_image_medium"
    t.string   "item_image_large"
    t.text     "item_link"
  end

  add_index "wishes", ["author"], :name => "author_index"
  add_index "wishes", ["item_price"], :name => "item_price_index"
  add_index "wishes", ["item_title"], :name => "item_title_index"
  add_index "wishes", ["publisher"], :name => "publisher_index"
  add_index "wishes", ["user_id", "jancode"], :name => "item_user_jancode", :unique => true

end
