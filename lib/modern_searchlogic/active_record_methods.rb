require_relative 'column_conditions'

module ModernSearchlogic
  module ActiveRecordMethods
    def self.included(base)
      base.include ColumnConditions
    end
  end
end
