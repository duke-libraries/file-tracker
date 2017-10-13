class AddIsAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.boolean :is_admin, default: false
    end
  end
end
