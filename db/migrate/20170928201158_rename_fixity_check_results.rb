class RenameFixityCheckResults < ActiveRecord::Migration[5.1]
  def change
    remove_column :fixity_check_results, :path, :text, limit: 4096, null: false, index: { length: 255 }, default: ''
    rename_table :fixity_check_results, :fixity_checks
  end
end
