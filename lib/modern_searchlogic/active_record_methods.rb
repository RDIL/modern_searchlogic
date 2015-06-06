require_relative 'default_scoping'
require_relative 'scope_tracking'
require_relative 'column_conditions'
require_relative 'scope_procedure'
require_relative 'searchable'

module ModernSearchlogic
  module ActiveRecordMethods
    def self.included(base)
      base.include DefaultScoping
      base.include ScopeTracking
      base.include ColumnConditions
      base.include ScopeProcedure
      base.include Searchable
    end
  end
end
