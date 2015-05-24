module ModernSearchlogic
  module ColumnConditions
    module ClassMethods
      SEARCHLOGIC_TO_AREL_MAPPING = {
        :equals => :eq,
        :eq => :eq,
        :does_not_equal => :not_eq,
        :ne => :not_eq,
        :greater_than => :gt,
        :gt => :gt,
        :less_than => :lt,
        :lt => :lt,
        :greater_than_or_equal_to => :gteq,
        :gte => :gteq,
        :less_than_or_equal_to => :lteq,
        :lte => :lteq,
        :in => :in,
        :eq_any => :in,
        :not_in => :not_in,
        :not_eq_any => :not_in,
      }

      def respond_to_missing?(method, *)
        super || !!searchlogic_column_condition_method_block(method.to_s)
      end

      def searchlogic_column_suffix(suffix, &method_block)
        searchlogic_column_suffixes << [suffix, method_block]
      end

      private

      def searchlogic_suffix_match(method_name)
        searchlogic_column_suffixes.lazy.map do |suffix, method_block|
          if match = method_name.match(/\A(#{column_names_regexp})#{suffix}\z/)
            lambda { |*args| instance_exec(match[1], *args, &method_block) }
          end
        end.find(&:present?)
      end

      def searchlogic_column_condition_method_block(method)
        method = method.to_s

        searchlogic_arel_mapping_match(method) ||
          searchlogic_suffix_match(method)
      end

      def column_names_regexp
        column_names.join('|')
      end

      def searchlogic_arel_mapping_match(method_name)
        searchlogic_matcher_re = SEARCHLOGIC_TO_AREL_MAPPING.keys.join('|')

        if match = method_name.match(/\A(#{column_names_regexp})_(#{searchlogic_matcher_re})\z/)
          arel_matcher = SEARCHLOGIC_TO_AREL_MAPPING.fetch(match[2].to_sym)

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
        base.searchlogic_column_suffixes = []

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
      end
    end
  end
end
