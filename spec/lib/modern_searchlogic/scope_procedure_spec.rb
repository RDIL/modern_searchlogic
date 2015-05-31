require 'rails_helper'

describe ModernSearchlogic::ScopeProcedure do
  specify { described_class.should_not be_nil }

  before do
    Post.scope_procedure :posts_for_home_page, lambda { Post.published.descend_by_published_at }
  end

  specify do
    Post.posts_for_home_page.to_sql.should ==
      Post.where(Post.arel_table[:published_at].not_eq(nil)).
           order(:published_at => :desc).to_sql
  end
end
