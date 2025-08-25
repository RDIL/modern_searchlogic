class AddBackupUserIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :backup_user_id, :integer
  end
end
