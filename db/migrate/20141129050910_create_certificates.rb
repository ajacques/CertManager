class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :subject, nullable: false
      t.string :common_name, nullable: true
      t.string :public_key_data, nullable: true
      t.string :private_key_data, nullable: false
      t.integer :issuer_id, nullable: true
      t.datetime :not_before, nullable: true
      t.datetime :not_after, nullable: true

      t.timestamps
    end
  end
end
