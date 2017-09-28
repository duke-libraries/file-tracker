class RenameFixityCheckResults < ActiveRecord::Migration[5.1]
  def change
    rename_table :fixity_check_results, :fixity_checks
  end
end
