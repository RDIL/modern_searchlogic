module ModernSearchlogic
  module ScopeProcedure
    def self.included(base)
      base.singleton_class.class_eval do
        alias_method :scope_procedure, :scope
      end
    end
  end
end
