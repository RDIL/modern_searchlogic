require_relative '../../migration_compatibility_helper'

class CreatePosts < ActiveRecordMigration
  def change
    create_table :posts do |t|
      t.belongs_to :user
      t.string :title
      t.text :body
      t.datetime :published_at

      t.timestamps null: false
    end
  end
end
