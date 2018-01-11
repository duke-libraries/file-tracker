class RemoveStatusFromTrackedFiles < ActiveRecord::Migration[5.1]
  def change
    remove_column :tracked_files, :status, :integer, limit: 1, default: 0, null: false, index: true
  end
end
