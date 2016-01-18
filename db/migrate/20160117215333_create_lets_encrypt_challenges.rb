class CreateLetsEncryptChallenges < ActiveRecord::Migration
  def change
    create_table :lets_encrypt_challenges do |t|
      t.integer :certificate_id, null: false
      t.string :domain_name, null: false
      t.integer :private_key_id, null: false
      t.string :token_key, null: false
      t.string :token_value, null: false
      t.string :verification_uri, null: false
    end
  end
end
