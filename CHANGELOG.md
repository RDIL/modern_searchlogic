# Changelog

# v1.1.1

No real changes since v1.1.0, just updating the lockfiles for the new version, which I previously forgot to do (and the publish failed as a result).
I've added a release checklist so that I don't forget in the future.

# v1.1.0

- Add `config.modern_searchlogic.auto_include`, which defaults to `true`. Set it to `false` to skip `ModernSearchlogic::ActiveRecordMethods.install` for more fine-grained control.
  - https://github.com/RDIL/modern_searchlogic/commit/1920df8468a91003d57b1a46f8b7326725bca210
- Modules now declare their own dependencies, so they can be included individually.
  - https://github.com/RDIL/modern_searchlogic/commit/e46dcc50f87c52f7d71965a9ba2782f7bb815e72
- Minor reductions in allocations
- Fix critical performance issue that previously made the gem way too slow in `method_missing`-heavy apps
  - https://github.com/RDIL/modern_searchlogic/commit/deb6fdafe85bc92ed83d40245d44faf617ab0433
- Fix multiple deprecation warnings on Rails 4
  - https://github.com/RDIL/modern_searchlogic/commit/afdac5fab6030c1ca12408898b9059e022219095
  - https://github.com/RDIL/modern_searchlogic/commit/80d102dc68495eb1484cc1cd5609b435f22f239d

# v1.0.1

No changes, fixing bad publish.

# v1.0.0

This marks the first release of the fork. Changes from Genius/master:

- Add Rails 7 & 8 test apps.
- Upgrade to Ruby 3.3.
- [Fix column type discovery running too early](https://github.com/RDIL/modern_searchlogic/commit/28268a7ce6de89ee5a226e8271c4a116340e2e4b).
- [Support Rails 6](https://github.com/RDIL/modern_searchlogic/commit/ad4c9358914dff86a7615468b4c3533036ba2ffa).
- [Don't do column type discovery on abstract classes](https://github.com/RDIL/modern_searchlogic/commit/b47779bb53d25c32927d2557ffe268b79486c422).
