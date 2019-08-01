module ModernSearchlogic
  module ScopeProcedure
    def self.included(base)
      base.singleton_class.class_eval do
        def scope_procedure(name, options = nil)
          define_singleton_method name do |*args|
            case options
            when Symbol
              send(options)
            else
              options.call(*args)
            end
          end
        end
      end
    end
  end
end
