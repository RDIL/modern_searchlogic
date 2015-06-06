class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def self.is_like(something)
    "whoops"
  end

  scope :published, -> do
    where(arel_table[:published_at].not_eq(nil))
  end

  scope_procedure :posts_for_home_page, lambda { Post.published.descend_by_published_at }
end
