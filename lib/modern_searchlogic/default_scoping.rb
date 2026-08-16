module ModernSearchlogic
  module DefaultScoping
    extend ActiveSupport::Concern

    module ClassMethods
      def searchlogic_default_scope
        if Rails::VERSION::MAJOR < 4
          scoped
        else
          all
        end
      end
    end
  end
end
