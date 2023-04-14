# frozen_string_literal: true

require_relative 'lib/gem_updater/version'

Gem::Specification.new do |s|
  s.name        = 'gem_updater'
  s.version     = GemUpdater::VERSION
  s.summary     = 'Update your gems and find their changelogs'
  s.description = 'Updates the gems of your Gemfile ' \
                  'and fetches the links pointing to where their changelogs are'
  s.authors     = ['Maxime Demolin']
  s.email       = 'maxime_dev@demol.in'
  s.files       = Dir['{lib}/**/*']
  s.homepage    = 'https://github.com/MaximeD/gem_updater'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.0.0'

  s.add_runtime_dependency 'bundler',  '< 3'
  s.add_runtime_dependency 'json',     '~> 2.6'
  s.add_runtime_dependency 'memoist',  '~> 0.16.2'
  s.add_runtime_dependency 'nokogiri', '~> 1.13'

  s.add_development_dependency 'pry', '~> 0.14'
  s.add_development_dependency 'rspec',   '~> 3.12'
  s.add_development_dependency 'rubocop', '~> 1.41'
  s.add_development_dependency 'rubocop-performance', '~> 1.15'
  s.add_development_dependency 'vcr', '~> 6.1'
  s.add_development_dependency 'webmock', '~> 3.18'

  s.executables << 'gem_update'
  s.metadata['rubygems_mfa_required'] = 'true'
end
