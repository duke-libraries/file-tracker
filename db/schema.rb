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

ActiveRecord::Schema.define(version: 20170920203306) do

  create_table "fixity_check_results", force: :cascade do |t|
    t.text "path", limit: 4096, null: false
    t.string "sha1"
    t.string "md5"
    t.integer "size", limit: 8
    t.integer "status", null: false
    t.text "error"
    t.datetime "started_at", null: false
    t.datetime "finished_at", null: false
    t.index ["finished_at"], name: "index_fixity_check_results_on_finished_at"
    t.index ["path"], name: "index_fixity_check_results_on_path"
    t.index ["started_at"], name: "index_fixity_check_results_on_started_at"
    t.index ["status"], name: "index_fixity_check_results_on_status"
  end

  create_table "tracked_directories", force: :cascade do |t|
    t.string "path", null: false
    t.datetime "tracked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tracked_files", force: :cascade do |t|
    t.text "path", limit: 4096, null: false
    t.string "sha1"
    t.string "md5"
    t.integer "size", limit: 8
    t.datetime "fixity_checked_at"
    t.integer "fixity_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_tracked_files_on_created_at"
    t.index ["fixity_checked_at"], name: "index_tracked_files_on_fixity_checked_at"
    t.index ["fixity_status"], name: "index_tracked_files_on_fixity_status"
    t.index ["path"], name: "index_tracked_files_on_path"
    t.index ["size"], name: "index_tracked_files_on_size"
    t.index ["updated_at"], name: "index_tracked_files_on_updated_at"
  end

end
