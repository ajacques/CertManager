class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :private_key_data
      t.integer :public_key_id
      t.integer :issuer_id, null: true

      t.timestamps
    end
  end
end
