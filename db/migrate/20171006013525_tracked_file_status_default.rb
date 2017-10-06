class TrackedFileStatusDefault < ActiveRecord::Migration[5.1]
  def change
    TrackedFile.where(status: nil).update_all(status: 0)
    change_column :tracked_files, :status, :integer, null: false, default: 0, limit: 1, index: true
  end
end
