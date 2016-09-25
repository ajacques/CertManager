class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.integer
      t.string :name, null: false
      t.string :type, null: false

      t.timestamps null: false
      t.timestamp :last_checked_at
    end
  end
end
