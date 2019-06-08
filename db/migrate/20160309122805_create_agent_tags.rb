class CreateAgentTags < ActiveRecord::Migration[4.2]
  def change
    create_table :agent_tags do |t|
      t.integer :agent_id, null: false
      t.string :tag, null: false
    end
  end
end
