class AddTitleToTrackedDirectories < ActiveRecord::Migration[5.1]
  def change
    change_table :tracked_directories do |t|
      t.string :title
    end
  end
end
