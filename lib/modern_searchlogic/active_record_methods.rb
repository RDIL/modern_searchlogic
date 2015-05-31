require_relative 'scope_tracking'
require_relative 'column_conditions'
require_relative 'scope_procedure'

module ModernSearchlogic
  module ActiveRecordMethods
    def self.included(base)
      base.include ScopeTracking
      base.include ColumnConditions
      base.include ScopeProcedure
    end
  end
end
