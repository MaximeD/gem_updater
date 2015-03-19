Gem::Specification.new do |s|
  s.name        = 'gem_updater'
  s.version     = '0.0.2'
  s.date        = '2015-03-18'
  s.summary     = "Update your gems and find their changelogs"
  s.description = "It updates the gems of your Gemfile and fetches the links pointing to where their changelogs are"
  s.authors     = [ "Maxime Demolin" ]
  s.email       = 'akbarova.armia@gmail.com'
  s.files       = Dir["{lib}/**/*"]
  s.homepage    = 'https://github.com/MaximeD/gem_updater'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency 'bundler',   '~> 1.8'
  s.add_runtime_dependency 'json',      '~> 1.8'
  s.add_runtime_dependency 'nokogiri',  '~> 1.6'

  s.add_development_dependency 'rspec', '~> 3.0'

  s.executables << 'gem_update'
end
