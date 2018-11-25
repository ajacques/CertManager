class CreateAcmeSignAttempts < ActiveRecord::Migration
  def change
    create_table :acme_sign_attempts do |t|
      t.integer :certificate_id, null: false
      t.integer :private_key_id, null: false
      t.integer :imported_key_id

      t.string :last_status, default: 'unknown', null: false
      t.string :status_message

      t.string :acme_endpoint, null: false
      t.string :order_uri, null: false

      t.timestamps null: false
      t.timestamp :last_checked_at
    end
  end
end
