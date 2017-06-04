Gem::Specification.new do |s|
  s.name        = 'gem_updater'
  s.version     = '2.1'
  s.date        = '2017-03-17'
  s.summary     = 'Update your gems and find their changelogs'
  s.description = 'Updates the gems of your Gemfile and fetches the links pointing to where their changelogs are'
  s.authors     = ['Maxime Demolin']
  s.email       = 'akbarova.armia@gmail.com'
  s.files       = Dir["{lib}/**/*"]
  s.homepage    = 'https://github.com/MaximeD/gem_updater'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.1.0'

  s.add_runtime_dependency 'bundler',   '~> 1.15'
  s.add_runtime_dependency 'json',      '~> 2.1'
  s.add_runtime_dependency 'nokogiri',  '~> 1.7'

  s.add_development_dependency 'rspec', '~> 3.6'

  s.executables << 'gem_update'
end
