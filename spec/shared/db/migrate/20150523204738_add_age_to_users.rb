require_relative '../../migration_compatibility_helper'

class AddAgeToUsers < ActiveRecordMigration
  def change
    add_column :users, :age, :integer, :null => false, :default => 0
  end
end
