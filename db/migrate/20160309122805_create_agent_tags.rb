class CreateAgentTags < ActiveRecord::Migration
  def change
    create_table :agent_tags do |t|
      t.integer :agent_id, null: false
      t.string :tag, null: false
    end
  end
end
