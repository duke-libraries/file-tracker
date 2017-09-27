class AlterFixityCheckResultsTimestamps < ActiveRecord::Migration[5.1]
  def change
    change_table :fixity_check_results do |t|
      t.rename :created_at, :started_at
      t.rename :updated_at, :finished_at
    end
  end
end
