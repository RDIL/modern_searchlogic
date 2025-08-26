require_relative '../../migration_compatibility_helper'

class AddActiveToUsers < ActiveRecordMigration
  def change
    add_column :users, :active, :boolean
  end
end
