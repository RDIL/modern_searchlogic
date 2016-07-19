class User < ActiveRecord::Base
  has_many :posts

  has_many :votes, foreign_key: :voter_id
end
