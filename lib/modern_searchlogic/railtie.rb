module ModernSearchlogic
  class Railtie < Rails::Railtie
    initializer 'modern_searchlogic.setup_activerecord' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.__send__(:include, ModernSearchlogic::ActiveRecordMethods)
      end
    end
  end
end
