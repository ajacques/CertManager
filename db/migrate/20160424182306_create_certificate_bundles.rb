class CreateCertificateBundles < ActiveRecord::Migration
  def change
    create_table :certificate_bundles do |t|
      t.string :name, null: false, unique: true
    end
    create_table :certificate_bundles_public_keys do |t|
      t.integer :certificate_bundle_id, null: false
      t.integer :public_key_id, null: false
    end
    add_foreign_key :certificate_bundles_public_keys, :certificate_bundles
    add_foreign_key :certificate_bundles_public_keys, :public_keys
  end
end
