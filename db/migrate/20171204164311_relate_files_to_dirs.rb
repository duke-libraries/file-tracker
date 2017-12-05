class RelateFilesToDirs < ActiveRecord::Migration[5.1]
  def change
    change_table :tracked_files do |t|
      t.references :tracked_directory
    end
  end
end
