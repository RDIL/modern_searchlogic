require 'rails_helper'

describe ModernSearchlogic::ColumnConditions do
  context 'column_equals methods' do
    let!(:user) { User.create!(:username => 'Andrew') }

    specify '.username_equals returns a scope' do
      User.username_equals('Andrew').count.should == 1
    end

    specify '.username_equals returns the expected user' do
      User.username_equals('Andrew').first.should == user
    end
  end
end
