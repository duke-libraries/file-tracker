class RenameFixityCheckResultsError < ActiveRecord::Migration[5.1]
  def change
    change_table :fixity_check_results do |t|
      t.rename :error, :message
    end
  end
end
