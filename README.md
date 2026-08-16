# ModernSearchlogic

Searchlogic for Rails 3+!

Note: this is a fork of [Genius/modern_searchlogic](https://github.com/Genius/modern_searchlogic).
Unlike upstream, this repository is published to RubyGems (and has versioning).

## Supported Versions

The Gem is tested on Rails 3-8 (except 6, because I'm lazy), using the latest version available.
For the older versions, it uses Rails LTS so we don't need to maintain Ruby 3 patches here as well.

The gem *might* work on Ruby 2, but it is only tested against Ruby 3.3.

## Usage

Just add the Gem to your gemspec, and the searchlogic methods will be available.
Refer to the searchlogic documentation for more details.

## Configuration

By default the gem installs itself into every model, by including `ModernSearchlogic::ActiveRecordMethods` into `ActiveRecord::Base` (and `ModernSearchlogic::Ordering` into `ActiveRecord::Relation`) once ActiveRecord loads.

To opt-out and wire things up yourself, set the following in `config/application.rb` (it must be set before ActiveRecord loads, so an initializer is too late):

```ruby
config.modern_searchlogic.auto_include = false
```

With that off, nothing is included anywhere, and you pick the pieces you want:

```ruby
class User < ApplicationRecord
  include ModernSearchlogic::ColumnConditions  # username_like, age_gt, ascend_by_username, ...
  include ModernSearchlogic::ScopeProcedure    # scope_procedure :adults, -> { age_gte(18) }
  include ModernSearchlogic::Searchable        # User.search(:username_like => 'bob')
end
```

The modules pull in whatever they depend on (`Searchable` brings `ColumnConditions`, which brings `ScopeTracking`, and so on), so including only the one you want is safe.
HOWEVER, `ModernSearchlogic::Ordering` patches `order` on relations rather than on a model, so if you want `Model.order(:ascend_by_username)` to work, you need:

```ruby
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.include(ModernSearchlogic::Ordering)
end
```

Note that a module cannot be un-included from a class once it is in the ancestor chain, so `auto_include = false` is the only way to keep a model free of these methods.

## Contributing

Optional, but required for running specs against Rails 3-5: a [Rails LTS](https://railslts.com) subscription.
If you do have one, create a `.bundle/config` with contents:

```yaml
---
BUNDLE_GEMS__RAILSLTS__COM: "theusername:thepassword"
```

- Install Ruby 3.3
- Run `bundler install`
- If you DON'T have a Rails LTS subscription, comment out the Rails 3-5 appraisals in the `Appraisal` file
- Run `bundler exec appraisal install`
- Start the database. You can use Docker compose to do this the easy way. If you go the manual route, make sure authentication is optional
- You are now ready!

## Running Specs

```shell
# Run for ALL Rails versions:
$ bundle exec rake test

# OR for a specific Rails version only (replace 7 with the major version of Rails):
$ bundle exec rake rspec7
```
