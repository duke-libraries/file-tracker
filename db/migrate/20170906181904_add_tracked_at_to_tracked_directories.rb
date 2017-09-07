class AddTrackedAtToTrackedDirectories < ActiveRecord::Migration[5.1]
  def change
    change_table :tracked_directories do |t|
      t.datetime :tracked_at, null: true
    end
  end
end
