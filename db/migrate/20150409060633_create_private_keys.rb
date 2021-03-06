class CreatePrivateKeys < ActiveRecord::Migration[4.2]
  def change
    create_table :private_keys do |t|
      t.string :type, null: false
      t.integer :bit_length
      t.string :curve_name
      t.string :fingerprint, null: false
      t.binary :body, null: false

      t.timestamps null: false
    end

    add_foreign_key :certificates, :private_keys
    add_index :private_keys, :fingerprint
  end
end
