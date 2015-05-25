class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def self.is_like(something)
    "whoops"
  end
end
