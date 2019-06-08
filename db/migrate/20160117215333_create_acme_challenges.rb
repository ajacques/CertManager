class CreateAcmeChallenges < ActiveRecord::Migration[4.2]
  def change
    create_table :acme_challenges do |t|
      t.integer :acme_sign_attempt_id, null: false
      t.string :domain_name, null: false

      t.string :last_status, null: false, default: 'unchecked'
      t.json :error_message

      t.string :token_key, null: false
      t.string :token_value, null: false

      t.string :verification_uri, null: false

      t.timestamps null: false
      t.datetime :acme_checked_at
      t.datetime :expires_at, null: false
    end
  end
end
