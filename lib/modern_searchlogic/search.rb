module ModernSearchlogic
  class Search
    def self.search(model_class, options = {})
      underlying_scope = model_class.searchlogic_default_scope

      options.each do |k, v|
        k = k.to_sym
        if k.to_s == 'order'
          if model_class.valid_searchlogic_scope?(v) && model_class.searchlogic_method_arity(v).zero?
            underlying_scope = underlying_scope.__send__(v)
          end
        elsif model_class.valid_searchlogic_scope?(k)
          if model_class.searchlogic_method_arity(k).zero?
            unless v.to_s == 'false'
              underlying_scope = underlying_scope.__send__(k)
            end
          else
            underlying_scope = underlying_scope.__send__(k, v)
          end
        end
      end

      new(model_class, underlying_scope)
    end

    def initialize(model_class, underlying_scope)
      @model_class, @underlying_scope = model_class, underlying_scope
    end

    def respond_to_missing?(method, *)
      super || underlying_scope.respond_to?(method)
    end

    delegate :inspect, :to => :underlying_scope

    def inspect
      "#<#{self.class} scope=#{underlying_scope.inspect}>"
    end

    private

    attr_reader :model_class, :underlying_scope

    def method_missing(method, *args, &block)
      return super unless underlying_scope.respond_to?(method)

      result = underlying_scope.__send__(method, *args, &block)

      if ActiveRecord::Relation === result
        new(model_class, result)
      else
        result
      end
    end
  end
end
