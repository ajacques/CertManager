class CreateAuthorizations < ActiveRecord::Migration[4.2]
  def change
    create_table :authorizations do |t|
      t.integer :o_auth_provider_id, null: false
      t.string :authorization_type, null: false
      t.string :identifier, null: false
      t.string :display_name, null: false
      t.string :display_image
      t.string :display_image_host # Pulled from display_image. Allows CSP headers to be quickly generated
      t.string :url

      t.timestamps null: false
      t.timestamp :last_checked_at
    end
  end
end
