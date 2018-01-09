class RemoveDuracloudData < ActiveRecord::Migration[5.1]
  def up
    drop_table :duracloud_manifest_entries if table_exists?(:duracloud_manifest_entries)
    remove_columns :tracked_directories, :duracloud_space, :duracloud_checked_at
    remove_columns :tracked_files, :duracloud_status, :duracloud_checked_at, :md5
    remove_column :fixity_checks, :md5
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
