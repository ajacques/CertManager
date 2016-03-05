class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :registration_token
    end
  end
end
