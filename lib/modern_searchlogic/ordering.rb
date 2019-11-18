module ModernSearchlogic
  module Ordering
    def self.included(base)
      base.extend ClassMethods
    end

    def self.prepended(base)
      base.prepend ClassMethods
    end

    module ClassMethods
      def order(expression)
        match_data = expression.to_s.match(/^(ascend|descend)_by_(.*)/)
        return super unless match_data

        direction = match_data.captures.first
        column = match_data.captures.second
        if direction == 'ascend'
          order(arel_table[column].asc)
        else
          order(arel_table[column].desc)
        end
      end
    end
  end
end
