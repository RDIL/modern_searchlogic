# frozen_string_literal: true

module ModernSearchlogic
  class Railtie < Rails::Railtie
    config.modern_searchlogic = ActiveSupport::OrderedOptions.new
    config.modern_searchlogic.auto_include = true

    initializer 'modern_searchlogic.setup_activerecord' do |app|
      ActiveSupport.on_load(:active_record) do
        ModernSearchlogic::ActiveRecordMethods.install if app.config.modern_searchlogic.auto_include
      end
    end
  end
end
