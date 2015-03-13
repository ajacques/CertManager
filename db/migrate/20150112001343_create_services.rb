class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :certificate_id, null: false
      t.string :cert_path, null: false
      t.string :after_rotate, null: false
      t.string :deploy_strategy, null: false
      t.string :node_group, null: false
      t.timestamp :last_deployed

      t.timestamps null: false
    end
  end
end
