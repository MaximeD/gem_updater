# frozen_string_literal: true

require 'gem_updater'
require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

SimpleCov.start

Dir["#{File.expand_path('support', __dir__)}/*.rb"].sort.each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
end
