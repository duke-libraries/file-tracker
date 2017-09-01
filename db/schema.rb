# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170901200728) do

  create_table "tracked_directories", force: :cascade do |t|
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_tracked_directories_on_path"
  end

  create_table "tracked_files", force: :cascade do |t|
    t.string "path", limit: 65535, null: false
    t.string "sha1", null: false
    t.string "md5", null: false
    t.integer "size", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "fixity_checked_at"
    t.integer "fixity_status"
    t.index ["created_at"], name: "index_tracked_files_on_created_at"
    t.index ["path"], name: "index_tracked_files_on_path"
    t.index ["size"], name: "index_tracked_files_on_size"
    t.index ["updated_at"], name: "index_tracked_files_on_updated_at"
  end

end
