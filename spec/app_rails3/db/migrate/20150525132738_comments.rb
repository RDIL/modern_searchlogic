class Comments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.belongs_to :post, :null => false
      t.timestamps :null => false
    end
  end
end
