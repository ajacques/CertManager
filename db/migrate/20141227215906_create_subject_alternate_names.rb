class CreateSubjectAlternateNames < ActiveRecord::Migration
  def change
    create_table :subject_alternate_names do |t|
      t.integer :certificate_, nullable: false
      t.string :name, nullable: false
    end
  end
end
