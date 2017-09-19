class AllowNulls < ActiveRecord::Migration[5.1]
  def change
    change_column_null :tracked_files, :size, true
    change_column_null :tracked_files, :md5, true
    change_column_null :tracked_files, :sha1, true
  end
end
