module ModernSearchlogic
  module DefaultScoping
    module ClassMethods
      def searchlogic_default_scope
        respond_to?(:scoped) ? scoped : all
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
