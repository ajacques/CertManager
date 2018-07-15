class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :type, null: false
      t.integer :certificate_id, null: false
      t.jsonb :properties, null: false
      t.timestamp :last_deployed

      t.timestamps null: false
    end
    add_foreign_key :services, :certificates
  end
end
