require 'rails_helper'

describe 'compiled matcher pattern cache' do
  def prime_cache!(model)
    model.respond_to?(:definitely_not_a_searchlogic_scope)
  end

  it "compiles a model's patterns once and reuses them" do
    prime_cache!(User)
    before = User.__send__(:searchlogic_patterns)
    User.respond_to?(:another_miss)

    User.__send__(:searchlogic_patterns).should equal before
  end

  it 'keeps patterns per-model rather than sharing them' do
    prime_cache! User
    prime_cache! Post

    User.__send__(:searchlogic_patterns).should_not equal Post.__send__(:searchlogic_patterns)
    User.should respond_to :username_like
    User.should_not respond_to :title_like
    Post.should respond_to :title_like
  end

  it 'picks up an association defined after the cache was built' do
    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'posts'
      def self.name; 'CachePost'; end
    end

    prime_cache!(klass)
    klass.should_not respond_to :editor_username_like

    klass.belongs_to :editor, :class_name => 'User', :foreign_key => :user_id

    klass.should respond_to :editor_username_like
  end

  it 'picks up a column added after the cache was built' do
    connection = ActiveRecord::Base.connection

    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
      def self.name; 'CacheUser'; end
    end

    prime_cache!(klass)
    klass.should_not respond_to :nickname_like

    begin
      connection.add_column :users, :nickname, :string
      klass.reset_column_information
      User.reset_column_information

      klass.should respond_to :nickname_like
    ensure
      connection.remove_column :users, :nickname
      klass.reset_column_information
      User.reset_column_information
    end
  end

  it 'picks up a suffix condition registered after the cache was built' do
    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
      def self.name; 'CacheSuffixUser'; end
    end

    prime_cache!(klass)
    klass.should_not respond_to :username_is_wibbly

    begin
      ActiveRecord::Base.__send__(:searchlogic_suffix_condition, '_is_wibbly') do |column_name|
        arel_table[column_name].eq('wibbly')
      end

      klass.should respond_to :username_is_wibbly
      klass.username_is_wibbly.to_sql.should include 'wibbly'
    ensure
      ActiveRecord::Base.searchlogic_suffix_conditions.delete('_is_wibbly')
      ModernSearchlogic.invalidate_regex_caches!
    end
  end

  it 'does not rebuild patterns when nothing has changed' do
    prime_cache! User
    version = ModernSearchlogic.regex_cache_version

    500.times { User.respond_to?(:definitely_not_a_searchlogic_scope) }

    ModernSearchlogic.regex_cache_version.should == version
  end
end
