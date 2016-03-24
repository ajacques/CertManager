class CreateSubjectAlternateNames < ActiveRecord::Migration
  def change
    create_table :subject_alternate_names do |t|
      t.string :name, null: false
    end
  end
end
