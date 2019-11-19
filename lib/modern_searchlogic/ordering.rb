module ModernSearchlogic
  module Ordering
    def self.included(base)
      base.module_eval do
        define_method(:order_with_modern_searchlogic) do |*args|
          args.reduce(self) do |scope, arg|
            expression = arg.to_s
            if expression.match(/^(ascend|descend)_by_(.*)/) && respond_to?(expression)
              scope.send(expression)
            else
              scope.order_without_modern_searchlogic(arg)
            end
          end
        end
        alias_method :order_without_modern_searchlogic, :order
        alias_method :order, :order_with_modern_searchlogic
      end
    end
  end
end
