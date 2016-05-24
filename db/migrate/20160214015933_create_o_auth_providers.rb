class CreateOAuthProviders < ActiveRecord::Migration
  def change
    create_table :o_auth_providers do |t|
      t.string :name, null: false
      t.string :requested_scopes, null: false

      # URIs
      t.string :authorize_uri_base, null: false
      t.string :token_uri_base, null: false

      # Service Authentication
      t.string :client_id
      t.string :client_secret
    end
    add_index :o_auth_providers, :name, unique: true
  end
end
