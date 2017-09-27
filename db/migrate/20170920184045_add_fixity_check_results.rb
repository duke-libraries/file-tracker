class AddFixityCheckResults < ActiveRecord::Migration[5.1]
  def change
    create_table :fixity_check_results do |t|
      t.text    :path, limit: 4096, null: false, index: { length: 255 }
      t.string  :sha1
      t.string  :md5
      t.integer :size, limit: 8
      t.integer :status, null: false, index: true
      t.text    :error
      t.timestamps null: false, index: true
    end
  end
end
