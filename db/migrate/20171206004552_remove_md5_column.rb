class RemoveMd5Column < ActiveRecord::Migration[5.1]
  def change
    remove_column :tracked_files, :md5, :string
    remove_column :fixity_checks, :md5, :string
  end
end
