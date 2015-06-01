require_relative 'search'

module ModernSearchlogic
  module Searchable
    module ClassMethods
      def search(options = {})
        Search.search(self, options)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
