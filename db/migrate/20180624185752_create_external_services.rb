class CreateExternalServices < ActiveRecord::Migration[5.2]
  def change
    create_table :external_services do |t|
      t.string :endpoint_uri
      t.string :credential_type
      t.jsonb :credential

      t.timestamps
    end
  end
end
