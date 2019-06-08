class CreateSubjects < ActiveRecord::Migration[4.2]
  def change
    create_table :subjects do |t|
      t.string :CN
      t.string :O
      t.string :OU
      t.string :C
      t.string :ST
      t.string :L
    end
  end
end
