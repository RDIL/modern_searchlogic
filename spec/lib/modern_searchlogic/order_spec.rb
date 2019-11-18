require 'rails_helper'

describe ModernSearchlogic::Ordering do
  context 'ordering by column on an ActiveRecordmodel' do
    let!(:younger) { User.create!(age: 14) }
    let!(:older) { User.create!(age: 18) }

    specify { User.order(:descend_by_age).first.should == older }
    specify { User.order(:ascend_by_age).first.should == younger }
  end

  context 'ordering by column an an ActiveRecord::Relation' do
    let!(:user) { User.create! }
    let!(:newer) { Post.create!(created_at: 2.days.ago, published_at: Time.now, user: user) }
    let!(:older) { Post.create!(created_at: 7.days.ago, published_at: Time.now, user: user) }

    specify { Post.published.order(:descend_by_created_at).should == [newer, older] }
    specify { Post.published.order(:ascend_by_created_at).should == [older, newer] }
  end
end
