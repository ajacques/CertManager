class CreateSubjectAlternateNames < ActiveRecord::Migration[4.2]
  def change
    create_table :subject_alternate_names do |t|
      t.string :name, null: false
    end
  end
end
