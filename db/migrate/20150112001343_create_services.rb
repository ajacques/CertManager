class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :certificate_id
      t.string :cert_path
      t.string :after_rotate

      t.timestamps null: false
    end
  end
end
