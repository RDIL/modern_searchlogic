require 'rails_helper'

describe ModernSearchlogic::Ordering do
  let!(:baby) { User.create!(age: 0, username: 'baby') }
  let!(:teenager) { User.create!(age: 14, username: 'teenager') }
  let!(:adult_1) { User.create!(age: 30, username: 'adult_1') }
  let!(:adult_2) { User.create!(age: 30, username: 'adult_2') }
  let!(:senior) { User.create!(age: 65, username: 'senior') }

  let!(:newer_teenager_post) { Post.create!(created_at: 2.days.ago, published_at: Time.now, user: teenager) }
  let!(:older_teenager_post) { Post.create!(created_at: 7.days.ago, published_at: Time.now, user: teenager) }

  let!(:newer_senior_post) { Post.create!(created_at: 3.days.ago, published_at: Time.now, user: senior) }
  let!(:older_senior_post) { Post.create!(created_at: 14.days.ago, published_at: Time.now, user: senior) }

  context 'ordering by column on an ActiveRecord model' do
    specify { User.order(:descend_by_age).first.should == senior }
    specify { User.order(:ascend_by_age).first.should == baby }
  end

  context 'ordering by column on an ActiveRecord::Relation' do
    specify { Post.published.order(:descend_by_created_at).first.should == newer_teenager_post }
    specify { Post.published.order(:ascend_by_created_at).first.should == older_senior_post }
  end

  context 'ordering on a column through an association' do
    specify { teenager.posts.order(:descend_by_created_at).first.should == newer_teenager_post }
    specify { teenager.posts.published.order(:descend_by_created_at).first.should == newer_teenager_post }

    specify { teenager.posts.order(:ascend_by_created_at).first.should == older_teenager_post }
    specify { teenager.posts.published.order(:ascend_by_created_at).first.should == older_teenager_post }
  end

  context 'chaning the association as part of the order expression' do
    specify do
      Post.order(:descend_by_user_age).should == [newer_senior_post, older_senior_post, newer_teenager_post, older_teenager_post]
      Post.order(:descend_by_user_age, :published_at).should == [newer_senior_post, older_senior_post, newer_teenager_post, older_teenager_post]
      Post.order(:descend_by_user_age, :descend_by_published_at).should == [older_senior_post, newer_senior_post, older_teenager_post, newer_teenager_post]
    end
  end

  context 'ordering by multiple columns' do
    specify do
      expected = User.order(:age, :username).to_a
      expected.should == [baby, teenager, adult_1, adult_2, senior]
      User.order(:ascend_by_age, :username).should == expected
      User.order(:ascend_by_age, :ascend_by_username).should == expected
    end

    specify do
      expected = User.order(:age, 'username DESC').to_a
      expected.should == [baby, teenager, adult_2, adult_1, senior]
      User.order(:age, :descend_by_username).should == expected
      User.order(:ascend_by_age, :descend_by_username).should == expected
    end

    specify do
      expected = User.order('age DESC', :username).to_a
      expected.should == [senior, adult_1, adult_2, teenager, baby]
      User.order(:descend_by_age, :username).should == expected
    end

    specify do
      expected = User.order(:username, 'age DESC').to_a
      expected.should == [adult_1, adult_2, baby, senior, teenager]
      User.order(:username, :descend_by_age).should == expected
    end
  end
end
