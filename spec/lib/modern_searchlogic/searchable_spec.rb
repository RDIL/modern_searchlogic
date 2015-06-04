require 'rails_helper'

describe ModernSearchlogic::Searchable do
  specify { described_class.should_not be_nil }
  specify { User.search.should_not be_nil }

  context 'searches should invoke scopes' do
    subject do
      User.search(:username_eq => 'andrew', :email_eq_any => ['d@z.com', 'f@q.com', 'p@l.edu']).to_sql
    end

    it { should == User.username_eq('andrew').email_eq_any('d@z.com', 'f@q.com', 'p@l.edu').to_sql }

    context 'calling non-scope methods' do
      let!(:user) { User.create! }

      specify 'should be ignored' do
        User.search(:destroy_all => true)
        user.should_not be_nil
      end
    end
  end

  context 'calling methods with 0 arity' do
    subject do
      User.search(:descend_by_username => true).to_sql.should == User.descend_by_username.to_sql
    end

    subject do
      User.search(:descend_by_username => 'true').to_sql.should == User.descend_by_username.to_sql
    end

    context 'on associations' do
      subject do
        User.search(:descend_by_posts_title => true).to_sql
      end

      it { should == User.descend_by_posts_title.to_sql }
    end

    context 'with search option set to false' do
      specify do
        User.search(:descend_by_username => false).to_sql.should == User.all.to_sql
      end

      specify do
        User.search(:descend_by_username => 'false').to_sql.should == User.all.to_sql
      end
    end
  end
end
