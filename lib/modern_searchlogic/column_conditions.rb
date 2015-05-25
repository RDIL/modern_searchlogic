module ModernSearchlogic
  module ColumnConditions
    module ClassMethods
      def respond_to_missing?(method, *)
        super || !!searchlogic_column_condition_method_block(method.to_s)
      end

      private

      def searchlogic_column_suffix(suffix, &method_block)
        searchlogic_column_suffixes << [suffix, method_block]
      end

      def searchlogic_column_prefix(prefix, &method_block)
        searchlogic_column_prefixes << [prefix, method_block]
      end

      def searchlogic_arel_alias(searchlogic_suffix, arel_method)
        searchlogic_to_arel_mappings[searchlogic_suffix] = arel_method
      end

      def searchlogic_prefix_suffix_match(method_name)
        searchlogic_column_suffixes.each do |suffix, method_block|
          if match = method_name.match(/\A(#{column_names_regexp})#{suffix}\z/)
            return lambda { |*args| instance_exec(match[1], *args, &method_block) }
          end
        end

        searchlogic_column_prefixes.each do |prefix, method_block|
          if match = method_name.match(/\A#{prefix}(#{column_names_regexp})\z/)
            return lambda { |*args| instance_exec(match[1], *args, &method_block) }
          end
        end

        nil
      end

      def searchlogic_column_condition_method_block(method)
        method = method.to_s
        searchlogic_arel_mapping_match(method) || searchlogic_prefix_suffix_match(method)
      end

      def column_names_regexp
        column_names.join('|')
      end

      def searchlogic_arel_mapping_match(method_name)
        searchlogic_matcher_re = searchlogic_to_arel_mappings.keys.join('|')

        if match = method_name.match(/\A(#{column_names_regexp})_(#{searchlogic_matcher_re})\z/)
          arel_matcher = searchlogic_to_arel_mappings.fetch(match[2].to_sym)

          lambda do |val|
            where(arel_table[match[1]].__send__(arel_matcher, val))
          end
        end
      end

      def method_missing(method, *args, &block)
        return super unless method_block = searchlogic_column_condition_method_block(method.to_s)

        singleton_class.__send__(:define_method, method, &method_block)

        __send__(method, *args, &block)
      end
    end

    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        class_attribute :searchlogic_column_suffixes
        self.searchlogic_column_suffixes = []

        class_attribute :searchlogic_column_prefixes
        self.searchlogic_column_prefixes = []

        class_attribute :searchlogic_to_arel_mappings
        self.searchlogic_to_arel_mappings = {}

        searchlogic_arel_alias :equals, :eq
        searchlogic_arel_alias :eq, :eq
        searchlogic_arel_alias :is, :eq
        searchlogic_arel_alias :does_not_equal, :not_eq
        searchlogic_arel_alias :ne, :not_eq
        searchlogic_arel_alias :greater_than, :gt
        searchlogic_arel_alias :gt, :gt
        searchlogic_arel_alias :less_than, :lt
        searchlogic_arel_alias :lt, :lt
        searchlogic_arel_alias :greater_than_or_equal_to, :gteq
        searchlogic_arel_alias :gte, :gteq
        searchlogic_arel_alias :less_than_or_equal_to, :lteq
        searchlogic_arel_alias :lte, :lteq
        searchlogic_arel_alias :in, :in
        searchlogic_arel_alias :eq_any, :in
        searchlogic_arel_alias :not_in, :not_in
        searchlogic_arel_alias :not_eq_any, :not_in

        searchlogic_column_suffix '_like' do |column_name, val|
          where(arel_table[column_name].matches("%#{val}%"))
        end

        searchlogic_column_suffix '_begins_with' do |column_name, val|
          where(arel_table[column_name].matches("#{val}%"))
        end

        searchlogic_column_suffix '_ends_with' do |column_name, val|
          where(arel_table[column_name].matches("%#{val}"))
        end

        searchlogic_column_suffix '_not_like' do |column_name, val|
          where(arel_table[column_name].does_not_match("%#{val}%"))
        end

        searchlogic_column_suffix '_not_begin_with' do |column_name, val|
          where(arel_table[column_name].does_not_match("#{val}%"))
        end

        searchlogic_column_suffix '_not_end_with' do |column_name, val|
          where(arel_table[column_name].does_not_match("%#{val}"))
        end

        searchlogic_column_suffix '_blank' do |column_name|
          where(arel_table[column_name].eq(nil).or(arel_table[column_name].eq('')))
        end

        searchlogic_column_suffix '_present' do |column_name|
          where(arel_table[column_name].not_eq(nil).and(arel_table[column_name].not_eq('')))
        end

        null_matcher = lambda { |column_name| where(arel_table[column_name].eq(nil)) }
        searchlogic_column_suffix '_null', &null_matcher
        searchlogic_column_suffix '_nil', &null_matcher

        not_null_matcher = lambda { |column_name| where(arel_table[column_name].not_eq(nil)) }
        searchlogic_column_suffix '_not_null', &not_null_matcher
        searchlogic_column_suffix '_not_nil', &not_null_matcher

        searchlogic_column_prefix 'descend_by_' do |column_name|
          order(column_name => :desc)
        end

        searchlogic_column_prefix 'ascend_by_' do |column_name|
          order(column_name => :asc)
        end
      end
    end
  end
end
