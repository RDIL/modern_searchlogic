require 'rails_helper'

describe ModernSearchlogic::ColumnConditions do
  shared_examples 'a column condition' do |finder_method|
    let!(:user) { User.create!(user_attributes) }

    specify "#{finder_method} returns a countable scope" do
      User.__send__(finder_method, find_by).count.should == 1
    end

    specify "#{finder_method} returns the expected user" do
      User.__send__(finder_method, find_by).first.should == user
    end
  end

  context 'column_equals methods' do
    let(:user_attributes) { {:username => 'Andrew'} }
    let(:find_by) { 'Andrew' }

    it_should_behave_like 'a column condition', :username_equals
    it_should_behave_like 'a column condition', :username_eq
  end
end
