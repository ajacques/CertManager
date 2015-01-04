class CreatePublicKeys < ActiveRecord::Migration
  def change
    create_table :public_keys do |t|
      t.string :subject, null: false
      t.string :common_name, null: false
      t.string :body, null: false
      t.string :modulus_hash, null: false
      t.datetime :not_before, null: false
      t.datetime :not_after, null: false

      t.timestamps null: false
    end
  end
end
