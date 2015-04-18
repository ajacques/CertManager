class CreateSubjectAlternateNames < ActiveRecord::Migration
  def change
    create_table :subject_alternate_names do |t|
      t.integer :public_key_id, null: false
      t.string :name, null: false
    end
  end
end
