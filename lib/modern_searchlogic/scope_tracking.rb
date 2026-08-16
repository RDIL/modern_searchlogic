module ModernSearchlogic
  module ScopeTracking
    extend ActiveSupport::Concern

    included do
      class_attribute :_defined_scopes
      self._defined_scopes = Set.new
      class_attribute :_dynamically_defined_searchlogic_scopes
      self._dynamically_defined_searchlogic_scopes = {}
    end

    module ClassMethods
      def scope(name, body, &block)
        super(name, body, &block).tap do |*|
          self._defined_scopes |= [name.to_sym]
        end
      end
    end
  end
end
