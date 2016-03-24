class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :type, null: false
      t.integer :certificate_id, null: false
      t.string :properties, null: false
      t.timestamp :last_deployed

      t.timestamps null: false
    end
  end
end
