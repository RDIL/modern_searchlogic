require 'rails_helper'

describe ModernSearchlogic::ScopeTracking do
  it 'should track scopes on a per-model basis' do
    Post._defined_scopes.should include :published
    User._defined_scopes.should_not include :published
  end
end
