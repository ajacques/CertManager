class CreateCertificateRequests < ActiveRecord::Migration
  def change
    create_table :certificate_requests do |t|
      t.string :subject, null: false
      t.string :body, null: false
      t.string :key, null: false
      t.integer :certificate_id, null: false

      t.timestamps null: false
    end
  end
end
