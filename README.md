
# ModernSearchlogic

[![Build Status](https://travis-ci.org/Genius/modern_searchlogic.svg?branch=master)](https://travis-ci.org/Genius/modern_searchlogic)

Searchlogic for Rails 3+

## Getting Started

- Make sure you've got `rbenv` installed with the version of ruby in `ruby-version` installed
- Run `bundle`

## Running Specs

Make sure that you've got all of the rubies listed in `.travis.yml` installed

```
$ bundle exec rake
```

## Running specs for individual rails/ruby versions

- Set your `rbenv` shell to the version of ruby you want to test, if different from what is in `.ruby-version`
- To test rails 5, e.g., run `bundle exec appraisal rails-5 rspec`

Note: if you haven't run the main `rake` task yet, you might need to run that or the below command:

```
bundle exec appraisal rails-5 "cd spec/app_rails5/ && rake db:create db:migrate db:test:prepare && rake db:environment:set RAILS_ENV=test"
```
