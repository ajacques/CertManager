class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false, unique: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.binary :password_hash, null: false
      t.binary :password_salt, null: false
      t.boolean :can_login, null: false, default: false
      t.string :time_zone, null: false, default: 'Europe/London'

      # ACME Auth
      t.boolean :lets_encrypt_accepted_terms, null: false, default: false
      t.string :lets_encrypt_registration_uri, null: true

      # GitHub authentication
      t.string :github_username
      t.string :github_access_token
      t.string :github_scope

      t.timestamps null: false
    end
  end
end
