require_relative '../../migration_compatibility_helper'

class AddEmailToUsers < ActiveRecordMigration
  def change
    add_column :users, :email, :string
  end
end
