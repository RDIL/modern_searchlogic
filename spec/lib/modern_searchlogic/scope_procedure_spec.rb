require 'rails_helper'

describe ModernSearchlogic::ScopeProcedure do
  let!(:post_1) { Post.create!(user: user_1, published_at: Time.now) }
  let!(:post_2) { Post.create!(user: user_2, published_at: Time.now) }
  let!(:user_1) { User.create! }
  let!(:user_2) { User.create! }

  specify { described_class.should_not be_nil }

  specify do
    Post.for_home_page.to_sql.should ==
      Post.where(Post.arel_table[:published_at].not_eq(nil)).
           order(Post.arel_table[:published_at].desc).to_sql
  end

  it 'passes single arguments through' do
    Post.published_for_user(user_1).should =~ [post_1]
    Post.published_for_user(user_2).should =~ [post_2]
    Post.published_for_users(user_1, user_2).should =~ [post_1, post_2]
  end

  it 'passes multiple arguments through' do
    Post.published_for_users(user_1, user_2).should =~ [post_1, post_2]
  end

  it 'handles arity correctly when scope_procedure is passed a proc' do
    search = Post.search(order: :descend_by_created_at)
    search.active = true
    search.all.should =~ [post_1, post_2]
  end

  context 'and the scope procedure does not return a scope' do
    it 'returns the result of the scope procedure' do
      Post.published_grouped_by_user.should eq(
        user_1 => [post_1],
        user_2 => [post_2]
      )
    end

    it 'can be chained on earlier scopes and scope_procedures (that return scopes)' do
      Post.where(user_id: user_1.id).for_home_page.published_grouped_by_user.should eq(
        user_1 => [post_1]
      )
    end
  end

  it 'can combine associations and scope procedures' do
    User.posts_for_home_page.to_a.should == Post.published.descend_by_published_at.map(&:user)
  end
end
