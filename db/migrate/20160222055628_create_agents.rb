class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :access_token
      t.string :last_hostname

      t.timestamp :last_synced_at
    end
  end
end
