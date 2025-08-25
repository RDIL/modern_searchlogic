$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "modern_searchlogic/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "modern_searchlogic"
  s.version     = ModernSearchlogic::VERSION
  s.authors     = ["Andrew Warner"]
  s.email       = ["wwarner.andrew@gmail.com"]
  s.homepage    = "https://github.com/Genius/modern_searchlogic"
  s.summary     = "Searchlogic, but for AREL"
  s.description = "Because it's rampant through your codebase and you can't upgrade to rails 3 otherwise"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 3.2.14"

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'dotenv', '~> 2.0'
end
