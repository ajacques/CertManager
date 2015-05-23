class CreateCertificateSignRequests < ActiveRecord::Migration
  def change
    create_table :certificate_sign_requests do |t|
      t.integer :certificate_id, null: false
      t.integer :subject_id, null: false
      t.integer :private_key_id, null: false
    end
  end
end
