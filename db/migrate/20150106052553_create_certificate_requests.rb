class CreateCertificateRequests < ActiveRecord::Migration
  def change
    create_table :certificate_requests do |t|
      t.integer :subject_id
      t.string :body

      t.timestamps null: false
    end
  end
end
