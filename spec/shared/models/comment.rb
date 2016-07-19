class Comment < ActiveRecord::Base
  belongs_to :post

  has_many :votes, as: :voteable
end
