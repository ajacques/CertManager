class CreatePublicKeys < ActiveRecord::Migration
  def change
    create_table :public_keys do |t|
      t.integer :subject_id, null: false
      t.integer :private_key_id
      t.integer :issuer_subject_id
      t.string :key_type, null: false
      t.string :curve_name
      t.string :hash_algorithm, null: false
      t.integer :bit_length
      t.boolean :is_ca, null: false
      t.datetime :not_before, null: false
      t.datetime :not_after, null: false

      t.binary :body, null: false
      t.string :fingerprint

      t.timestamps null: false
    end
  end
end
