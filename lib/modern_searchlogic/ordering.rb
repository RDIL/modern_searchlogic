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
        if expression.to_s.match(/^(ascend|descend)_by_(.*)/) && respond_to?(expression)
          send(expression)
        else
          super
        end
      end
    end
  end
end
