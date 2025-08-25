class CreatePosts < ActiveRecord::Migration[5.2]
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
