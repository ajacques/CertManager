class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :private_key_id
      t.integer :subject_id, null: false
      t.integer :public_key_id
      t.integer :issuer_id
      t.string :chain_hash, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false

      t.timestamps
    end
  end
end
