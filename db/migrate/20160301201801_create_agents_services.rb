class CreateAgentsServices < ActiveRecord::Migration[4.2]
  def change
    create_table :agents_services do |t|
      t.integer :agent_id, null: false
      t.integer :service_id, null: false
    end
  end
end
