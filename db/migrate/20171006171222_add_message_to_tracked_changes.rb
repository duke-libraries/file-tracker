class AddMessageToTrackedChanges < ActiveRecord::Migration[5.1]
  def change
    change_table :tracked_changes do |t|
      t.text :message
    end
  end
end
