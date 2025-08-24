require 'dotenv'

Dotenv.load

appraise "rails-3" do
  source ENV.fetch("RAILS_LTS_CREDENTIALS") do
    gem "rails", "~> 3.2"
  end
  gem "rake", "~> 12.0"
  gem "pg"
  gem "rspec", "~> 2.14"
  gem "rspec-rails", "~> 2.14"
  gem "rspec-its"
  gem "test-unit"
  gem "pry"
  gem "strong_parameters"
  gem "ruby3-backward-compatibility"
  gem "bigdecimal"
  gem "base64"
  gem "racc"
end

appraise "rails-4" do
  source ENV.fetch("RAILS_LTS_CREDENTIALS") do
    gem "rails", "~> 4.2"
  end
  gem "rake", "~> 12.0"
  gem "pg"
  gem "rspec", "~> 3.0"
  gem "rspec-rails", "~> 3.0"
  gem "rspec-its"
  gem "pry"
  gem "ruby3-backward-compatibility"
  gem "mutex_m"
  gem "bigdecimal"
  gem "base64"
end

appraise "rails-5" do
  source ENV.fetch("RAILS_LTS_CREDENTIALS") do
    gem "rails", "~> 5.2"
  end
  gem "rake", "~> 13.0"
  gem "pg"
  gem "listen"
  gem "rspec", "~> 3.0"
  gem "rspec-rails", "~> 5.0"
  gem "rspec-its"
  gem "pry"
  gem "ruby3-backward-compatibility"
  gem "mutex_m"
  gem "bigdecimal"
end

appraise "rails-6" do
  source ENV.fetch("RAILS_LTS_CREDENTIALS") do
    gem "rails", "~> 6"
  end
  gem "rake", "~> 13.0"
  gem "pg"
  gem "listen"
  gem "rspec", "~> 3.0"
  gem "rspec-rails", "~> 6.0"
  gem "rspec-its"
  gem "pry"
end
