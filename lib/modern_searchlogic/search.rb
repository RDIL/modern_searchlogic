module ModernSearchlogic
  class Search
    def self.search(model_class, options = {})
      underlying_scope = model_class

      options.each do |k, v|
        k = k.to_sym
        if model_class.valid_searchlogic_scope?(k)
          underlying_scope = underlying_scope.__send__(k, v)
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
