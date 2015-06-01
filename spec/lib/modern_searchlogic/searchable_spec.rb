require 'rails_helper'

describe ModernSearchlogic::Searchable do
  specify { described_class.should_not be_nil }
  specify { User.search.should_not be_nil }

  context 'searches should invoke scopes' do
    subject do
      User.search(:username_eq => 'andrew', :email_eq_any => ['d@z.com', 'f@q.com', 'p@l.edu']).to_sql
    end

    it { should == User.username_eq('andrew').email_eq_any('d@z.com', 'f@q.com', 'p@l.edu').to_sql }
  end
end
