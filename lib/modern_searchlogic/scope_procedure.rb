module ModernSearchlogic
  module ScopeProcedure
    def self.included(base)
      base.singleton_class.class_eval do
        def scope_procedure(name, options = nil)
          self._defined_scopes << name.to_sym
          define_singleton_method name do |*args|
            case options
            when Symbol
              public_send(options, *args)
            else
              options.call(*args)
            end
          end
        end
      end
    end
  end
end
