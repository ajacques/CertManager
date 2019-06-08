class RemoveLoginFromUsers < ActiveRecord::Migration[5.1]
  def self.up
    %i[reset_password_token reset_password_sent_at remember_created_at
       confirmation_token confirmed_at confirmation_sent_at].each do |col|
      remove_column :users, col
    end
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
