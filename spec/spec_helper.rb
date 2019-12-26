# frozen_string_literal: true

require 'codacy-coverage'
require 'gem_updater'
require 'simplecov'

Codacy::Reporter.start
SimpleCov.start

Dir["#{File.expand_path('support', __dir__)}/*.rb"].sort.each { |file| require file }

RSpec.configure do |config|
  config.include Spec::Helpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
end
