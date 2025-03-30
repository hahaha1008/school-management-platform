class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :password
      t.string :role
      t.datetime :expire_date

      t.timestamps
    end
  end
end
