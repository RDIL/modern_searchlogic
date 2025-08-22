if RUBY_VERSION >= "3.0"
  unless File.respond_to?(:exists?)
    class << File
      alias_method :exists?, :exist?
    end
  end
  
  unless Dir.respond_to?(:exists?)
    class << Dir
      alias_method :exists?, :exist?
    end
  end
end
