require_relative '../../migration_compatibility_helper'

class CreateUsers < ActiveRecordMigration
  def change
    create_table :users do |t|
      t.string :username

      t.timestamps null: false
    end
  end
end
