class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def self.is_like(something)
    "whoops"
  end

  def self.published
    where(arel_table[:published_at].not_eq(nil))
  end
end
