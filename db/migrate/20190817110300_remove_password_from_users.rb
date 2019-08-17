class RemovePasswordFromUsers < ActiveRecord::Migration[5.1]
  def self.up
    %i[password_hash password_salt].each do |col|
      remove_column :users, col
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
