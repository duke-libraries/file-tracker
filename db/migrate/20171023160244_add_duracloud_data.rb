class AddDuracloudData < ActiveRecord::Migration[5.1]
  def change
    change_table :tracked_directories do |t|
      t.string   :duracloud_space
      t.datetime :duracloud_checked_at
    end

    change_table :tracked_files do |t|
      t.integer    :duracloud_status, index: true, limit: 1, null: false, default: -1
      t.datetime   :duracloud_checked_at, index: true
    end
  end
end
