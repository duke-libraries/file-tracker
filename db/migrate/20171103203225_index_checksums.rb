class IndexChecksums < ActiveRecord::Migration[5.1]
  def change
    add_index :tracked_files, :sha1
    add_index :tracked_files, :md5
  end
end
