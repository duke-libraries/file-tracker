class AddFixityToTrackedFiles < ActiveRecord::Migration[5.1]
  def change
    change_table :tracked_files do |t|
      t.datetime :fixity_checked_at, index: true
      t.integer :fixity_status, index: true
    end

    drop_table :fixity_checks do |t|
      t.references :tracked_file, foreign_key: true
      t.datetime   :checked_at,   null: false,    index: true
      t.integer    :outcome,      null: false,    index: true
    end
  end
end
