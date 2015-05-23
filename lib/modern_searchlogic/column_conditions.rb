module ModernSearchlogic
  module ColumnConditions
    module ClassMethods
      def respond_to_missing?(method, *)
        super || !!searchlogic_column_condition_method_block(method.to_s)
      end

      private

      def searchlogic_column_condition_method_block(method)
        searchlogic_equals_match(method.to_s) ||
          searchlogic_does_not_equal_match(method.to_s)
      end

      def column_names_regexp
        column_names.join('|')
      end

      def searchlogic_does_not_equal_match(method_name)
        if match = method_name.match(/\A(#{column_names_regexp})_(does_not_equal|ne)\z/)
          lambda { |val| where(arel_table[match[1]].not_eq(val)) }
        end
      end

      def searchlogic_equals_match(method_name)
        if match = method_name.match(/\A(#{column_names_regexp})_(equals|eq)\z/)
          lambda { |val| where(match[1] => val) }
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
    end
  end
end
