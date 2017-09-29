class AddForeignKeyToTrackedChanges < ActiveRecord::Migration[5.1]
  def change
    change_table :tracked_changes do |t|
      t.references :tracked_file
    end

    remove_column :tracked_changes, :path, :text, limit: 4096, null: false, index: { length: 255 }, default: ''
  end
end
