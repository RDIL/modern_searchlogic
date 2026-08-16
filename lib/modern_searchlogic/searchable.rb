require_relative 'search'

module ModernSearchlogic
  module Searchable
    extend ActiveSupport::Concern

    include DefaultScoping
    include ColumnConditions

    module ClassMethods
      def search(options = {})
        Search.search(self, options)
      end
    end
  end
end
