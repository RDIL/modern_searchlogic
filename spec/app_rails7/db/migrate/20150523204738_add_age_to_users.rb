class AddAgeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :age, :integer, :null => false, :default => 0
  end
end
