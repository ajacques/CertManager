class CreateKeyUsages < ActiveRecord::Migration[4.2]
  def change
    create_table :key_usages do |t|
      t.integer :public_key_id, null: false
      t.string :value, null: false
      t.string :group, null: false
    end
  end
end
