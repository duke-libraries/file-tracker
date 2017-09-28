class AddForeignKeyToFixityChecks < ActiveRecord::Migration[5.1]
  def change
    change_table :fixity_checks do |t|
      t.references :tracked_file
    end

    remove_column :fixity_checks, :path, :text, limit: 4096, null: false, index: { length: 255 }, default: ''
  end
end
