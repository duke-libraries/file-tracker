class DeviseCreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false, default: ""
      t.string :email
      t.string :encrypted_password, null: false, default: ""
      t.timestamps null: false
    end
  end
end
