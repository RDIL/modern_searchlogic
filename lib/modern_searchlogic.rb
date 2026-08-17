module ModernSearchlogic
  @regex_cache_version = 0

  class << self
    attr_reader :regex_cache_version

    def invalidate_regex_caches!
      @regex_cache_version += 1
    end
  end
end

require 'modern_searchlogic/active_record_methods'
require 'modern_searchlogic/railtie'
