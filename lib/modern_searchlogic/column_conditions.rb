module ModernSearchlogic
  module ColumnConditions
    module ClassMethods
      SEARCHLOGIC_TO_AREL_MAPPING = {
        :equals => :eq,
        :eq => :eq,
        :does_not_equal => :not_eq,
        :ne => :not_eq
      }

      def respond_to_missing?(method, *)
        super || !!searchlogic_column_condition_method_block(method.to_s)
      end

      private

      def searchlogic_column_condition_method_block(method)
        method = method.to_s

        searchlogic_arel_mapping_match(method) ||
          searchlogic_like_match(method) ||
          searchlogic_not_like_match(method)
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

      def searchlogic_like_match(method_name)
        if match = method_name.match(/\A(#{column_names_regexp})_like\z/)
          lambda { |val| where(arel_table[match[1]].matches("%#{val}%")) }
        end
      end

      def searchlogic_not_like_match(method_name)
        if match = method_name.match(/\A(#{column_names_regexp})_not_like\z/)
          lambda { |val| where(arel_table[match[1]].does_not_match("%#{val}%")) }
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
