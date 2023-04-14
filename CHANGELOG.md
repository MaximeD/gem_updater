# master (unreleased)

Deprecated:
* ruby 3.0 is the minimum required ruby version

Updates:
* gems

# v6.0.0 (April 5, 2023)

Deprecated:
* support for ruby `2.7`

Updates:
* gems

Fix:
* encoding compatibility between template and changes

# v5.1.0 (December 26, 2022)

Enhancement:
* add support for ruby 3.2

Updates:
* gems

# v5.0.0 (March 31, 2022)

Development tools:
* add `version` file

Updates:
* gems

Deprecated:
* support for ruby `2.5` and `2.6`

# v4.5.0 (January 2, 2022)

Enhancement:
* add support for ruby 3.1

Updates:
* gems

# v4.4.2 (July 14, 2021)

Updates:
* gems

# v4.4.1 (February 02, 2021)

Fix:
* take changelog file instead of directory if both are present (which is the case for rubocop for instance)

Updates:
* gems

# v4.4.0 (January 17, 2021)

Fix:
* uninitialized constant GemUpdater::Updater::ERB

Updates:
* gems

# v4.3.0 (June 29, 2020)

Fix:
* changelogs not found on github since they revamped their UI

Updates:
* `bundler` to version 2 (@anthony-robin)
* update gems

# v4.1.0 (January 19, 2020)

Updates:
* update gems

Enhancement:
* add support for ruby 2.7.0
* add rubocop performance

# v4.0.0 (November 03, 2019)

Deprecations:
* ruby 2.4 and below are now deprecated

Updates:
* `bundler` to version 2 (@anthony-robin)
* gems and dependencies

Development tools:
* add CI support for ruby 2.6.0
* add sleep stub in specs
* add rubocop

# v3.0.0 (March 10, 2018)

Deprecations:
* ruby 2.2 is now deprecated

Development tools:
* add CI support for ruby 2.5.0

Updates:
* gems and dependencies

# v2.1.3 (November 19, 2017)

Updates:
* gems and dependencies

# v2.1.2 (July 02, 2017)

Updates:
* nokogiri to `1.8`

# v2.1.1 (June 04, 2017)

Updates:
* gems and dependencies

# v2.1 (March 13, 2017)

Fix:
* parsing urls with `x-oauth-token`

Development tools:
* add gemnasium badge

# v2.0 (January 1, 2017)

Deprecations:
* ruby 2.1 is now deprecated in order to use latest nokogiri with ruby 2.4


# v1.0 (October 28, 2016)

**Switch to SemVer.**

Fix:
* compatibility with bundler 1.13


# v0.5.2 (July 11, 2016)

Fix:
* css selector for github

Updates:
* gems and dependencies

Development tools:
* add `bundler` caching on travis
* add code coverage
* add codacy badges

# v0.5.1 (May 24, 2016)

Fix:
* `https` redirection for `rubygems.org`

# v0.5.0 (April 09, 2016)

Fix:
* using other source with [rubygems](rubygems.org) (@oelmekki)

Enhancement:
* add ruby `2.3` to travis

Refactor:
* global refactor

# v0.4.5 (February 13, 2016)

Fix:
* making too many requests in a row to [rubygems](rubygems.org)

# v0.4.4 (October 27, 2015)

Fix:
* considering `''` as a valid url to parse

# 0.4.3 (October 15, 2015)

Enhancement:
* add recognition of `news` as a changelog name (@mattmenefee)

# 0.4.2 (October 02, 2015)

Enhancement:
* add recognition of `Changes` as a changelog name
* add support of `textile` files

# 0.4.1 (August 11, 2015)

Fix:
* when changelog is not found, it returns an object instead of `nil`

# 0.4.0 (July 25, 2015)

You can now update only a set of gems (just as bundler does).

example:
```
gem_update gem1 gem2
```

Moreover, fetching changelog is now multithreaded.
Depending on how many gems were updated,
you should see a major speedup.


Enhancement:
* allow to update only given gems
* refactor logger (use `Bundler.ui`)
* add multithreading

# 0.3.2 (July 23, 2015)

Fix:
* net timeouts


# 0.3.1 (May 19, 2015)

Fix:
* redirections over https for bitbucket


# 0.3.0 (Apr 11, 2015)

Add ability to auto commit the changes with option `--commit`.

Features
* auto commit (@oelmekki)
* update message when gems were already up-to-date

Fix:
* fix redirections on github subdomains


# 0.2.0 (Apr 06, 2015)

Add support for other sources (like `rails-assets`).

Fix:
* fix a bug when a gem has been removed from dependencies


# 0.1.1 (March 31, 2015)

Fix:
* redirections over https


# 0.1.0 (March 19, 2015)

Upgrade to support latest `bundler` version

Fix:
* fix compatibility with `bundler` 1.8 (@chourobin)


# 0.0.2 (March 16, 2015)

Update gemspec to specify minimum ruby version.

Features:
* add minimal ruby version in gemspec


# 0.0.1 (March 14, 2015)

First commit of gem.

Features:
* updating gems
* fetching github changelog
* specs
