class DropFixityChecksAndTrackedChanges < ActiveRecord::Migration[5.1]
  def up
    drop_table :tracked_changes
    drop_table :fixity_checks
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
