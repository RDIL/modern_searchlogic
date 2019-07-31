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

    context 'searches should handle nil column values' do
      subject do
        User.search(:username_eq => nil, :email_eq_any => ['d@z.com', 'f@q.com', 'p@l.edu']).to_sql
      end

      it { should == User.username_eq(nil).email_eq_any('d@z.com', 'f@q.com', 'p@l.edu').to_sql }
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
        User.search(:descend_by_username => false).to_sql.should == User.searchlogic_default_scope.to_sql
      end

      specify do
        User.search(:descend_by_username => 'false').to_sql.should == User.searchlogic_default_scope.to_sql
      end
    end
  end

  context 'ordering' do
    specify do
      User.search(:order => :descend_by_created_at).to_sql.should ==
        User.descend_by_created_at.to_sql
    end
  end

  context 'reading and modifying the scope' do
    subject do
      User.search(
        :order => :descend_by_created_at,
        :age_gt => 7,
        :username_eq => 'andrew'
      )
    end

    its(:username_eq) { should == 'andrew' }
    its(:age_gt) { should == 7 }
    its(:order) { should == :descend_by_created_at }

    specify do
      subject.age_gt = 10
      subject.age_gt.should == 10
    end

    specify do
      new_search = subject.age_gt(10)
      new_search.age_gt.should == 10
      subject.age_gt.should == 7
    end

    specify do
      subject.descend_by_updated_at = true

      subject.to_sql.should ==
        User.descend_by_created_at.
             age_gt(7).
             username_eq('andrew').
             descend_by_updated_at.
             to_sql
    end
  end

  context 'handling non-searchlogic conditions ' do
    let!(:andrew){UserWithDefaultScope.create!(username: 'andrew', email: 'andrew@test.org')}
    let!(:nate){UserWithDefaultScope.create!(username: 'nate',  email: 'nate@test.org')}

    it "searches with a non-searchlogic condition" do
      UserWithDefaultScope.search(username: 'nate').all.should == [nate]
    end

    it "searches with a searchlogic condition and a non-searchlogic condition" do
      UserWithDefaultScope.search(username_eq: 'andrew', email: 'andrew@test.org').all.should == [andrew]
      UserWithDefaultScope.search(username_eq: 'nate', email: 'foo@test.org').all.should == []
    end
  end
end
