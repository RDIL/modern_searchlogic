require 'rails_helper'

describe ModernSearchlogic::Railtie do
  let(:initializer) do
    described_class.initializers.detect { |i| i.name == 'modern_searchlogic.setup_activerecord' }
  end

  let(:config) { Rails.application.config.modern_searchlogic }

  around do |example|
    was = config.auto_include
    example.run
    config.auto_include = was
  end

  it 'auto includes by default' do
    config.auto_include.should be true
    ActiveRecord::Base.should be < ModernSearchlogic::ActiveRecordMethods
    ActiveRecord::Relation.should be < ModernSearchlogic::Ordering
  end

  it 'installs when auto_include is true' do
    config.auto_include = true
    expect(ModernSearchlogic::ActiveRecordMethods).to receive(:install)
    initializer.run(Rails.application)
  end

  it 'does not install when auto_include is false' do
    config.auto_include = false
    expect(ModernSearchlogic::ActiveRecordMethods).not_to receive(:install)
    initializer.run(Rails.application)
  end
end
