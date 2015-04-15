class CreatePrivateKeys < ActiveRecord::Migration
  def change
    create_table :private_keys do |t|
      t.string :key_type, null: false
      t.integer :bit_length, null: false
      t.string :curve_name
      t.string :fingerprint, null: false
      t.string :pem

      t.timestamps null: false
    end
  end
end
