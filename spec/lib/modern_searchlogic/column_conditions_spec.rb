require 'rails_helper'

describe ModernSearchlogic::ColumnConditions do
  shared_examples 'a column condition' do |*args|
    finder_method, user_attributes, find_by = *args
    let!(:user) { User.create!(user_attributes) }

    specify "#{finder_method} returns a countable scope" do
      User.__send__(*[finder_method, find_by].compact).count.should == 1
    end

    specify "#{finder_method} returns the expected user" do
      User.__send__(*[finder_method, find_by].compact).first.should == user
    end

    specify "#{finder_method} should get defined by calling it" do
      User.__send__(*[finder_method, find_by].compact)
      User.methods.should include finder_method
      Post.methods.should_not include finder_method
    end

    specify 'the wrong arity should raise an error' do
      error_args = find_by ? [] : ['foobar']

      expect { User.__send__(finder_method, *error_args) }.to raise_error ArgumentError
    end
  end

  context 'column_equals methods' do
    it_should_behave_like 'a column condition', :username_equals, {:username => 'Andrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_eq, {:username => 'Andrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_is, {:username => 'Andrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_does_not_equal, {:username => 'NotAndrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_ne, {:username => 'NotAndrew'}, 'Andrew'
    it_should_behave_like 'a column condition', :username_like, {:username => 'Andrew Warner'}, 'warn'
    it_should_behave_like 'a column condition', :username_not_like, {:username => 'Andrew Renraw'}, 'warn'
    it_should_behave_like 'a column condition', :username_begins_with, {:username => 'Andrew Warner'}, 'And'
    it_should_behave_like 'a column condition', :username_not_begin_with, {:username => 'Andrew Warner'}, 'ndr'
    it_should_behave_like 'a column condition', :username_ends_with, {:username => 'Andrew Warner'}, 'rner'
    it_should_behave_like 'a column condition', :username_not_end_with, {:username => 'Andrew Warner'}, 'arne'
    it_should_behave_like 'a column condition', :age_greater_than, {:age => 17}, 16
    it_should_behave_like 'a column condition', :age_gt, {:age => 17}, 16
    it_should_behave_like 'a column condition', :age_greater_than_or_equal_to, {:age => 17}, 17
    it_should_behave_like 'a column condition', :age_greater_than_or_equal_to, {:age => 17}, 16
    it_should_behave_like 'a column condition', :age_gte, {:age => 17}, 17
    it_should_behave_like 'a column condition', :age_less_than, {:age => 17}, 19
    it_should_behave_like 'a column condition', :age_lt, {:age => 17}, 19
    it_should_behave_like 'a column condition', :age_less_than_or_equal_to, {:age => 17}, 17
    it_should_behave_like 'a column condition', :age_less_than_or_equal_to, {:age => 17}, 19
    it_should_behave_like 'a column condition', :age_lte, {:age => 17}, 17
    it_should_behave_like 'a column condition', :username_not_null, {:username => 'Andrew'}
    it_should_behave_like 'a column condition', :username_present, {:username => 'Andrew'}

    context 'presence' do
      before do
        User.create!(:username => nil)
        User.create!(:username => '')
      end
      it_should_behave_like 'a column condition', :username_present, {:username => ' A'}
    end

    it_should_behave_like 'a column condition', :username_not_nil, {:username => 'Andrew'}
    it_should_behave_like 'a column condition', :username_null, {}
    it_should_behave_like 'a column condition', :username_blank, {}

    context 'blank' do
      before do
        User.create!(:username => ' ')
        User.create!(:username => 'A')
      end
      it_should_behave_like 'a column condition', :username_blank, {:username => ''}
    end

    it_should_behave_like 'a column condition', :username_nil, {}
    it_should_behave_like 'a column condition', :username_in, {:username => 'Andrew'}, ['Andrew', 'Warner', 'William']
    it_should_behave_like 'a column condition', :username_eq_any, {:username => 'Andrew'}, ['Andrew', 'Warner', 'William']
    it_should_behave_like 'a column condition', :username_not_in, {:username => 'Dave'}, ['Andrew', 'Warner', 'William']
    it_should_behave_like 'a column condition', :username_not_eq_any, {:username => 'Dave'}, ['Andrew', 'Warner', 'William']

    context 'ordering' do
      let!(:younger) { User.create!(:age => 14) }
      let!(:older) { User.create!(:age => 18) }

      context '#ascend_by_age' do
        specify do
          User.ascend_by_age.first.should == younger
        end
      end

      context '#descend_by_age' do
        specify do
          User.descend_by_age.first.should == older
        end
      end
    end
  end

  context 'chaining' do
    let!(:user) { User.create!(:username => 'William Andrew Warner', :age => 28, :email => 'willandwar@gmail.com') }

    before do
      User.create!(:username => 'Jane Smith', :age => 23)
      User.create!(:username => 'John Smith', :age => 24)
      User.create!(:username => 'Jorah Mormont', :age => 51)
    end

    specify 'chaining scopes should work' do
      User.age_gt(25).username_like('andr').first.should == user
    end

    context 'using or' do
      specify do
        User.username_or_email_like('andwar').first.should == user
      end

      specify do
        User.username_or_email_like_all('andwar', 'gmail').first.should == user
      end

      specify do
        User.username_or_email_like_any('foobaz', 'warner').first.should == user
      end
    end
  end

  context 'searching associations' do
    let(:user) { User.create!(:username => 'Andrew') }
    let(:dave) { User.create!(:username => 'Dave') }

    before do
      user.posts.create!(:title => 'Modernizing searchlogic in a jiffy')

      daves_post = dave.posts.create!(:title => 'A lovely day')
      daves_post.comments.create(:body => 'I had a great walk on the beach')
    end

    specify do
      User.posts_title_like('searchlogic').first.should == user
    end

    specify do
      User.posts_comments_body_like('great walk').first.should == dave
    end

    specify 'custom scopes should work' do
      user.posts.first.update!(:published_at => Time.now)
      User.posts_published.first.should == user
    end

    specify 'when association method is not a scope should raise an exception' do
      expect { User.posts_is_like }.to raise_error ArgumentError
    end
  end
end
