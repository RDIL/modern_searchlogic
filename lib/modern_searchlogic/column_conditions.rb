module ModernSearchlogic
  module ColumnConditions
    module ClassMethods
      def respond_to_missing?(method, *)
        super || !!searchlogic_equals_match(method.to_s)
      end

      private

      def column_names_regexp
        column_names.join('|')
      end

      def searchlogic_equals_match(method_name)
        method_name.match(/\A(#{column_names_regexp})_equals\z/)
      end

      def method_missing(method, *args, &block)
        return super unless match = searchlogic_equals_match(method.to_s)

        singleton_class.__send__(:define_method, method) do |val|
          where(match[1] => val)
        end

        __send__(method, *args, &block)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
