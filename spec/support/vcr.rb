# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  # Use :none to ensure tests use only recorded cassette data
  # This prevents any live HTTP requests and ensures stable tests
  c.default_cassette_options = {
    record: :none,
    match_requests_on: %i[method uri],
    allow_unused_http_interactions: true
  }

  # Clean up dynamic headers that can cause mismatches
  c.before_record do |interaction|
    interaction.response.headers.delete('Date')
    interaction.response.headers.delete('Age')
    interaction.response.headers.delete('X-Timer')
    interaction.response.headers.delete('X-Request-Id')
    interaction.response.headers.delete('X-Runtime')
    interaction.response.headers.delete('X-Cache-Hits')
  end
end
