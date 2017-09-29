class CreateTrackedChanges < ActiveRecord::Migration[5.1]
  def change
    create_table :tracked_changes do |t|
      t.text     :path, limit: 4096, null: false, index: { length: 255 }
      t.string   :sha1
      t.integer  :size, limit: 8
      t.datetime :discovered_at, null: false, index: true
      t.integer  :change_type, length: 1, null: false, index: true
      t.integer  :change_status, length: 1, null: true, index: true
      t.timestamps null: false, index: true
    end
  end
end
