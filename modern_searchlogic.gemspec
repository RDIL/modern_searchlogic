$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "modern_searchlogic/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "modern_searchlogic"
  s.version     = ModernSearchlogic::VERSION
  s.authors     = ["Andrew Warner"]
  s.email       = ["wwarner.andrew@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ModernSearchlogic."
  s.description = "TODO: Description of ModernSearchlogic."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 3.2.14"

  s.add_development_dependency 'appraisal'
end
