class CreatePublicKeysSans < ActiveRecord::Migration[4.2]
  def change
    create_table :public_keys_sans do |t|
      t.integer :public_key_id, null: false
      t.integer :subject_alternate_name_id, null: false
    end
  end
end
