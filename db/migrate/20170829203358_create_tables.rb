class CreateTables < ActiveRecord::Migration[5.1]
  def change
    create_table :tracked_files do |t|
      t.string :path,  null: false, limit: 65535, index: { length: 255 }
      t.string :sha1,  null: false
      t.string :md5,   null: false
      t.integer :size, null: false, limit: 8,     index: true
      t.timestamps     null: false,               index: true
    end

    create_table :fixity_checks do |t|
      t.references :tracked_file, foreign_key: true
      t.datetime   :checked_at,   null: false,    index: true
      t.integer    :outcome,      null: false,    index: true
    end

    create_table :tracked_directories do |t|
      t.string :path, null: false, index: true
      t.timestamps    null: false
    end
  end
end
