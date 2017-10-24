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

ActiveRecord::Schema.define(version: 20171023160244) do

  create_table "fixity_checks", force: :cascade do |t|
    t.string "sha1"
    t.string "md5"
    t.integer "size", limit: 8
    t.integer "status", limit: 1, null: false
    t.text "message"
    t.datetime "started_at", null: false
    t.datetime "finished_at", null: false
    t.integer "tracked_file_id"
    t.index ["finished_at"], name: "index_fixity_checks_on_finished_at"
    t.index ["started_at"], name: "index_fixity_checks_on_started_at"
    t.index ["status"], name: "index_fixity_checks_on_status"
    t.index ["tracked_file_id"], name: "index_fixity_checks_on_tracked_file_id"
  end

  create_table "tracked_changes", force: :cascade do |t|
    t.string "sha1"
    t.integer "size", limit: 8
    t.datetime "discovered_at", null: false
    t.integer "change_type", limit: 1, null: false
    t.integer "change_status", limit: 1, default: -1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tracked_file_id"
    t.text "message"
    t.index ["change_status"], name: "index_tracked_changes_on_change_status"
    t.index ["change_type"], name: "index_tracked_changes_on_change_type"
    t.index ["created_at"], name: "index_tracked_changes_on_created_at"
    t.index ["discovered_at"], name: "index_tracked_changes_on_discovered_at"
    t.index ["tracked_file_id"], name: "index_tracked_changes_on_tracked_file_id"
    t.index ["updated_at"], name: "index_tracked_changes_on_updated_at"
  end

  create_table "tracked_directories", force: :cascade do |t|
    t.string "path", null: false
    t.datetime "tracked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "duracloud_space"
    t.datetime "duracloud_checked_at"
  end

  create_table "tracked_files", force: :cascade do |t|
    t.text "path", limit: 4096, null: false
    t.string "sha1"
    t.string "md5"
    t.integer "size", limit: 8
    t.datetime "fixity_checked_at"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duracloud_status", limit: 1, default: -1, null: false
    t.datetime "duracloud_checked_at"
    t.index ["created_at"], name: "index_tracked_files_on_created_at"
    t.index ["fixity_checked_at"], name: "index_tracked_files_on_fixity_checked_at"
    t.index ["path"], name: "index_tracked_files_on_path"
    t.index ["size"], name: "index_tracked_files_on_size"
    t.index ["status"], name: "index_tracked_files_on_status"
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
