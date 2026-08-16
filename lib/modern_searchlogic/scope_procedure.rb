module ModernSearchlogic
  module ScopeProcedure
    extend ActiveSupport::Concern

    include ScopeTracking

    module ClassMethods
      def scope_procedure(name, options = nil)
        if options.is_a?(Proc)
          define_singleton_method(name, &options)
        else
          define_singleton_method(name) do |*args|
            public_send(options, *args)
          end
        end
        self._defined_scopes << name.to_sym
      end
    end
  end
end
