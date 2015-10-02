# master (unreleased)

Enhancement:
* add recognition of `Changes` as a changelog

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
