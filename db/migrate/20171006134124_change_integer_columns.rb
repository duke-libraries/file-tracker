class ChangeIntegerColumns < ActiveRecord::Migration[5.1]
  def change
    TrackedChange.where(change_status: nil).update_all(change_status: -1)
    change_column :tracked_changes, :change_status, :integer, null: false, default: -1, index: true, limit: 1
    change_column :tracked_changes, :change_type, :integer, null: false, index: true, limit: 1
    change_column :fixity_checks, :status, :integer, null: false, index: true, limit: 1
  end
end
