class CreateMysqlCompatibleTables < ActiveRecord::Migration[5.1]
  def change
    create_table :tracked_files do |t|
      t.text     :path,              null: false, limit: 4096, index: { length: 255 }
      t.string   :sha1,              null: false
      t.string   :md5,               null: false
      t.integer  :size,              null: false, limit: 8,    index: true
      t.datetime :fixity_checked_at, null: true,               index: true
      t.integer  :fixity_status,     null: true,               index: true
      t.timestamps                   null: false,              index: true
    end

    create_table :tracked_directories do |t|
      t.string   :path,       null: false
      t.datetime :tracked_at, null: true
      t.timestamps            null: false
    end
  end
end
