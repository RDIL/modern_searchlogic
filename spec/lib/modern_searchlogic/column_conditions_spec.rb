require 'rails_helper'

describe ModernSearchlogic::ColumnConditions do
  shared_examples 'a column condition' do |finder_method, user_attributes, find_by|
    let!(:user) { User.create!(user_attributes) }

    specify "#{finder_method} returns a countable scope" do
      User.__send__(finder_method, find_by).count.should == 1
    end

    specify "#{finder_method} returns the expected user" do
      User.__send__(finder_method, find_by).first.should == user
    end

    specify "#{finder_method} should get defined by calling it" do
      User.__send__(finder_method, find_by)
      User.public_method(finder_method).should_not be_nil
    end
  end

  context 'column_equals methods' do
    it_should_behave_like 'a column condition', :username_equals, {:username => 'Andrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_eq, {:username => 'Andrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_does_not_equal, {:username => 'NotAndrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_ne, {:username => 'NotAndrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_like, {:username => 'Andrew Warner'}, 'warn'
    it_should_behave_like 'a column condition', :username_not_like, {:username => 'Andrew Renraw'}, 'warn'
    it_should_behave_like 'a column condition', :age_greater_than, {:age => 17}, 16
    it_should_behave_like 'a column condition', :age_gt, {:age => 17}, 16
    it_should_behave_like 'a column condition', :age_less_than, {:age => 17}, 19
    it_should_behave_like 'a column condition', :age_lt, {:age => 17}, 19
  end
end
