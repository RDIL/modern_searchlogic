begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'

$already_set_up_db = false

SUPPORTED_RAILS_VERSIONS = (3..5).to_a.concat([7]).freeze

def convert_appraisal_to_gemfile(appraisal_name)
  appraisal_name.tr('-', '_')
end

def setup_database(gemfile_path, test_app_dir)
  puts "Setting up database..."

  Dir.chdir(File.join(ENV['PROJECT_ROOT'], test_app_dir)) do
    unless $already_set_up_db
      sh({'BUNDLE_GEMFILE' => gemfile_path}, 'bundle exec rake db:create:all') || exit(1)
    end

    sh({'BUNDLE_GEMFILE' => gemfile_path}, 'bundle exec rake db:environment:set RAILS_ENV=test') || exit(1)

    unless $already_set_up_db
      sh({'BUNDLE_GEMFILE' => gemfile_path}, 'bundle exec rake db:schema:load') || exit(1)
    end
  end

  $already_set_up_db = true
end

def find_spec_files
  Dir.chdir(ENV['PROJECT_ROOT']) do
    Dir.glob('spec/**/*_spec.rb')
       .reject { |file| file.match?(/spec\/app_rails.*\//) }
       .map { |file| File.expand_path(file) }
  end
end

def run_specs(gemfile_path, test_app_dir, spec_files)
  current_rubylib = ENV['RUBYLIB'] || ''
  spec_path = File.join(ENV['PROJECT_ROOT'], 'spec')
  ENV['RUBYLIB'] = current_rubylib.empty? ? spec_path : "#{spec_path}:#{current_rubylib}"

  ENV['RAILS_ROOT'] = File.join(ENV['PROJECT_ROOT'], test_app_dir)

  Dir.chdir(File.join(ENV['PROJECT_ROOT'], test_app_dir)) do
    ruby3_compat = File.join(ENV['PROJECT_ROOT'], 'spec', 'ruby3_compatibility')

    cmd = [
      'bundle', 'exec', 'ruby',
      '-r', ruby3_compat,
      '-e', "require 'rspec/core'; RSpec::Core::Runner.run(ARGV)",
      *spec_files
    ]

    sh({'BUNDLE_GEMFILE' => gemfile_path}, *cmd) || exit(1)
  end
end

def run_specs_for_version(appraisal_name, test_app_dir)
  ENV['POSTGRES_URL'] ||= 'postgres://postgres:password@localhost:5432/postgres'
  ENV['RAILS_ENV'] ||= 'test'
  ENV['PROJECT_ROOT'] ||= `git rev-parse --show-toplevel`.strip

  gemfile_name = convert_appraisal_to_gemfile(appraisal_name)
  gemfile_path = File.join(ENV['PROJECT_ROOT'], 'gemfiles', "#{gemfile_name}.gemfile")

  puts "Running specs for #{appraisal_name} in #{test_app_dir}"
  puts "Using gemfile: #{gemfile_name}.gemfile"

  setup_database(gemfile_path, test_app_dir)
  spec_files = find_spec_files
  run_specs(gemfile_path, test_app_dir, spec_files)
  puts "Specs completed for #{appraisal_name}"
end

SUPPORTED_RAILS_VERSIONS.each do |version|
  desc "Run specs for Rails #{version}"
  task "rspec#{version}" do
    run_specs_for_version("rails-#{version}", "spec/app_rails#{version}")
  end
end

desc "Run specs for all versions of Rails"
task "test" => SUPPORTED_RAILS_VERSIONS.map { |it| "rspec#{it}".to_sym }

desc "Install appraisals"
task "install_appraisals" do
  sh("bundler exec appraisal install")
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ModernSearchlogic'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks
