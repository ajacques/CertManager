class CreatePublicKeys < ActiveRecord::Migration
  def change
    create_table :public_keys do |t|
      t.string :subject, null: false
      t.string :common_name, null: false
      t.string :body
      t.string :modulus_hash
      t.datetime :not_before
      t.datetime :not_after

      t.timestamps null: false
    end
  end
end
