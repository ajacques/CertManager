class CreateCsrSans < ActiveRecord::Migration
  def change
    create_table :csr_sans do |t|
      t.integer :certificate_sign_request_id, null: false
      t.integer :subject_alternate_name_id, null: false
    end
  end
end
