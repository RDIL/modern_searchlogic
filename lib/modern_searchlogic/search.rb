module ModernSearchlogic
  class Search
    def self.search(model_class, options = {})
      new(model_class).tap do |s|
        options.each do |k, v|
          k = k.to_sym
          s.apply_search(k, v)
        end
      end
    end

    def initialize(model_class, options = {})
      @model_class, @options = model_class, options
    end

    def respond_to_missing?(method, *)
      super ||
        searchlogic_default_scope.respond_to?(method) ||
        search_scope_method?(method)
    end

    def apply_search(scope_name, value)
      options.merge!(scope_name.to_sym => value)
    end

    def get_search_value(scope_name)
      options[scope_name]
    end

    def order=(new_order)
      options[:order] = new_order
    end

    def order
      options[:order]
    end

    private

    attr_reader :model_class, :options
    delegate :searchlogic_default_scope, :valid_searchlogic_scope?, :to => :model_class

    def materialize_scope
      scope = searchlogic_default_scope

      options.each do |k, v|
        if k.to_s == 'order'
          if model_class.valid_searchlogic_scope?(v) && model_class.searchlogic_method_arity(v).zero?
            scope = scope.__send__(v)
          end
        elsif model_class.valid_searchlogic_scope?(k)
          if model_class.searchlogic_method_arity(k).zero?
            unless v.to_s == 'false'
              scope = scope.__send__(k)
            end
          else
            scope = scope.__send__(k, *Array.wrap([v]))
          end
        end
      end

      scope
    end

    def search_scope_method?(method)
      method.to_s =~ /\A(\S+?)(=)?\z/ && valid_searchlogic_scope?($1)
    end

    def method_missing(method, *args, &block)
      if search_scope_method?(method)
        applied_args = args.many? ? args : args.first
        if method.to_s.ends_with?('=')
          apply_search(method.to_s.chomp('='), applied_args)
        else
          if args.present? || model_class.searchlogic_method_arity(method).zero?
            self.class.new(model_class, options.merge(method => args.present? ? applied_args : true))
          else
            get_search_value(method)
          end
        end
      elsif searchlogic_default_scope.respond_to?(method)
        materialize_scope.__send__(method, *args, &block)
      else
        super
      end
    end
  end
end
