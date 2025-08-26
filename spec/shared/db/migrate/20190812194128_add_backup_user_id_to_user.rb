require_relative '../../migration_compatibility_helper'

class AddBackupUserIdToUser < ActiveRecordMigration
  def change
    add_column :users, :backup_user_id, :integer
  end
end
