module ModernSearchlogic
  module ScopeTracking
    extend ActiveSupport::Concern

    included do
      class_attribute :_defined_scopes
      self._defined_scopes = Set.new
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
