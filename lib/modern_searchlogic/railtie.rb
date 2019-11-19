module ModernSearchlogic
  class Railtie < Rails::Railtie
    initializer 'modern_searchlogic.setup_activerecord' do
      ActiveSupport.on_load(:active_record) do
        ModernSearchlogic::ActiveRecordMethods.install
      end
    end
  end
end
