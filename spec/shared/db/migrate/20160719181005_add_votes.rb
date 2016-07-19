class AddVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.belongs_to :voteable, polymorphic: true, null: false
      t.integer :vote, null: false
      t.belongs_to :voter, null: false

      t.timestamps null: false
    end
  end
end
