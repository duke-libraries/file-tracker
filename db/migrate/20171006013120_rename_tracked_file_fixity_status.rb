class RenameTrackedFileFixityStatus < ActiveRecord::Migration[5.1]
  def change
    rename_column :tracked_files, :fixity_status, :status
  end
end
