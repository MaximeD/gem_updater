# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'gem_updater'
  s.version     = '4.1.0'
  s.date        = '2020-01-19'
  s.summary     = 'Update your gems and find their changelogs'
  s.description = 'Updates the gems of your Gemfile ' \
                  'and fetches the links pointing to where their changelogs are'
  s.authors     = ['Maxime Demolin']
  s.email       = 'akbarova.armia@gmail.com'
  s.files       = Dir['{lib}/**/*']
  s.homepage    = 'https://github.com/MaximeD/gem_updater'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.5.0'

  s.add_runtime_dependency 'bundler',  '< 3'
  s.add_runtime_dependency 'json',     '~> 2.1'
  s.add_runtime_dependency 'memoist',  '~> 0.16.0'
  s.add_runtime_dependency 'nokogiri', '~> 1.8'

  s.add_development_dependency 'rspec',   '~> 3.7'
  s.add_development_dependency 'rubocop', '~> 0.78'
  s.add_development_dependency 'rubocop-performance', '~> 1.5.2'

  s.executables << 'gem_update'
end
