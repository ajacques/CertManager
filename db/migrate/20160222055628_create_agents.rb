class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :access_token
    end
  end
end
