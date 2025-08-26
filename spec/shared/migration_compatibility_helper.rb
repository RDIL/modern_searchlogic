ActiveRecordMigration =
  if ActiveRecord::VERSION::MAJOR >= 5
    ActiveRecord::Migration[5.2]
  else
    ActiveRecord::Migration
  end
