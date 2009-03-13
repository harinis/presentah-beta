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

ActiveRecord::Schema.define(:version => 20090223184703) do

  create_table "interested_users", :force => true do |t|
    t.string "email"
  end

  create_table "presentations", :force => true do |t|
    t.integer  "user_id",                      :limit => 11, :null => false
    t.integer  "viddler_id",                   :limit => 11
    t.string   "viddler_filename"
    t.string   "title"
    t.string   "status"
    t.text     "description"
    t.text     "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "thumbnail"
    t.string   "viddler_url"
    t.integer  "length",                       :limit => 11
    t.text     "purpose"
    t.integer  "average_body_language_rating", :limit => 11
    t.integer  "average_voice_rating",         :limit => 11
    t.integer  "average_message_rating",       :limit => 11
    t.integer  "average_slides_rating",        :limit => 11
    t.integer  "average_overall_rating",       :limit => 11
  end

  create_table "ratings", :force => true do |t|
    t.integer  "user_id",              :limit => 11,                :null => false
    t.integer  "presentation_id",      :limit => 11,                :null => false
    t.integer  "body_language_rating", :limit => 11, :default => 0
    t.integer  "voice_rating",         :limit => 11, :default => 0
    t.integer  "message_rating",       :limit => 11, :default => 0
    t.integer  "slides_rating",        :limit => 11, :default => 0
    t.integer  "overall_rating",       :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username",   :null => false
    t.string   "password",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
