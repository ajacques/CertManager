class CreateRevocationEndpoints < ActiveRecord::Migration[4.2]
  def change
    create_table :revocation_endpoints do |t|
      t.integer :public_key_id, null: false
      t.string :endpoint, null: false
      t.string :uri_type, null: false
    end
  end
end
