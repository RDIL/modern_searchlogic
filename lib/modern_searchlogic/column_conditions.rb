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

      private

      def searchlogic_column_condition_method_block(method)
        method = method.to_s

        searchlogic_arel_mapping_match(method) ||
          searchlogic_like_match(method) ||
          searchlogic_not_like_match(method) ||
          searchlogic_null_match(method) ||
          searchlogic_presence_match(method)
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
        if match = method_name.match(/\A(#{column_names_regexp})_(ends_with|begins_with|like)\z/)
          lambda do |val|
            like_value =
              case match[2]
              when 'like'
                "%#{val}%"
              when 'begins_with'
                "#{val}%"
              when 'ends_with'
                "%#{val}"
              end

            where(arel_table[match[1]].matches(like_value))
          end
        end
      end

      def searchlogic_not_like_match(method_name)
        if match = method_name.match(/\A(#{column_names_regexp})_(not_end_with|not_begin_with|not_like)\z/)
          lambda do |val|
            like_value =
              case match[2]
              when 'not_like'
                "%#{val}%"
              when 'not_begin_with'
                "#{val}%"
              when 'not_end_with'
                "%#{val}"
              end

            where(arel_table[match[1]].does_not_match(like_value))
          end
        end
      end

      def searchlogic_null_match(method_name)
        if match = method_name.match(/\A(#{column_names_regexp})_((?:not_)?(?:null|nil))\z/)
          matcher = match[2].starts_with?('not_') ? :not_eq : :eq
          lambda { where(arel_table[match[1]].__send__(matcher, nil)) }
        end
      end

      def searchlogic_presence_match(method_name)
        if match = method_name.match(/\A(#{column_names_regexp})_(blank|present)\z/)
          arel_query =
            if match[2] == 'blank'
              arel_table[match[1]].eq(nil).or(arel_table[match[1]].eq(''))
            else
              arel_table[match[1]].not_eq(nil).and(arel_table[match[1]].not_eq(''))
            end

          lambda { where(arel_query) }
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
