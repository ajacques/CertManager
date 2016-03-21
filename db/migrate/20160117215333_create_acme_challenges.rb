class CreateAcmeChallenges < ActiveRecord::Migration
  def change
    create_table :acme_challenges do |t|
      t.integer :certificate_id, null: false
      t.integer :private_key_id, null: false

      t.string :last_status, null: false, default: 'unchecked'
      t.string :error_message

      t.string :token_key, null: false
      t.string :token_value, null: false

      t.string :verification_uri, null: false
      t.string :acme_endpoint, null: false

      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
    end
  end
end
