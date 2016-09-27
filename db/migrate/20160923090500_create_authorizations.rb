class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.integer :o_auth_provider_id, null: false
      t.string :authorization_type, null: false
      t.string :identifier, null: false

      t.timestamps null: false
      t.timestamp :last_checked_at
    end
  end
end
