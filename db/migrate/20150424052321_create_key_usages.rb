class CreateKeyUsages < ActiveRecord::Migration
  def change
    create_table :key_usages do |t|
      t.integer :public_key_id, null: false
      t.string :value, null: false
    end
  end
end
