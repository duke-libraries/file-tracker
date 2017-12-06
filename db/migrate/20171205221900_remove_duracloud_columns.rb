class RemoveDuracloudColumns < ActiveRecord::Migration[5.1]
  def up
    drop_table :duracloud_manifest_entries
    remove_columns :tracked_directories, :duracloud_space, :duracloud_checked_at
    remove_columns :tracked_files, :duracloud_status, :duracloud_checked_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
