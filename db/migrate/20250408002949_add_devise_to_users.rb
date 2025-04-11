# db/migrate/YYYYMMDDHHMMSS_add_devise_to_users.rb
class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      ## Database authenticatable
      t.string :email, null: true, default: nil
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
    end

    add_index :users, :email, unique: true, where: "email IS NOT NULL"
    add_index :users, :reset_password_token, unique: true
    
    # We need to update existing data to encrypt passwords
    # This will run a migration script to encrypt existing passwords
    reversible do |dir|
      dir.up do
        User.reset_column_information
        User.find_each do |user|
          # Get the plain password currently stored
          plain_password = user.password
          # Use Devise to encrypt it
          user.password = plain_password
          user.save(validate: false)
        end
      end
    end
    
    # Remove the plaintext password column after migration
    # You might want to keep it initially to ensure everything works
    # and then create a separate migration to remove it
    # remove_column :users, :password
  end
end