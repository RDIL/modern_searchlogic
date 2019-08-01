require 'rails_helper'

describe ModernSearchlogic::ScopeProcedure do
  specify { described_class.should_not be_nil }

  specify do
    Post.posts_for_home_page.to_sql.should ==
      Post.where(Post.arel_table[:published_at].not_eq(nil)).
           order(Post.arel_table[:published_at].desc).to_sql
  end

  context 'and the scope procedure does not return a scope' do
    let!(:post_1) { Post.create!(user: user_1, published_at: Time.now) }
    let!(:post_2) { Post.create!(user: user_2, published_at: Time.now) }
    let!(:user_1) { User.create! }
    let!(:user_2) { User.create! }

    it 'returns the result of the scope procedure' do
      Post.published_grouped_by_user.should eq(
        user_1 => [post_1],
        user_2 => [post_2]
      )
    end

    it 'can be chained on earlier scopes and scope_procedures (that return scopes)' do
      Post.where(user_id: user_1.id).posts_for_home_page.published_grouped_by_user.should eq(
        user_1 => [post_1]
      )
    end
  end
end
