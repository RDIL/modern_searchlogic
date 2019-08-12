class AddBackupUserIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :backup_user_id, :integer
  end
end
