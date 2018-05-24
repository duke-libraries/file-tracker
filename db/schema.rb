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

ActiveRecord::Schema.define(version: 20180111025904) do

  create_table "tracked_directories", force: :cascade do |t|
    t.string "path", null: false
    t.datetime "tracked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
  end

  create_table "tracked_files", force: :cascade do |t|
    t.text "path", limit: 4096, null: false
    t.string "sha1"
    t.integer "size", limit: 8
    t.datetime "fixity_checked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_tracked_files_on_created_at"
    t.index ["fixity_checked_at"], name: "index_tracked_files_on_fixity_checked_at"
    t.index ["path"], name: "index_tracked_files_on_path", length: 255
    t.index ["sha1"], name: "index_tracked_files_on_sha1"
    t.index ["size"], name: "index_tracked_files_on_size"
    t.index ["updated_at"], name: "index_tracked_files_on_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
  end

end
