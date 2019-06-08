class CreateCertificates < ActiveRecord::Migration[4.2]
  def change
    create_table :certificates do |t|
      t.integer :private_key_id
      t.integer :public_key_id
      t.integer :issuer_id
      t.string :chain_hash, null: false
      t.integer :created_by_id
      t.integer :updated_by_id

      t.integer :inflight_acme_sign_attempt_id
      t.string :auto_renewal_strategy

      t.timestamps
    end
  end
end
