# frozen_string_literal: true

require 'json'
require 'nokogiri'
require 'open-uri'

module GemUpdater
  # RubyGemsFetcher is a wrapper around rubygems API.
  class RubyGemsFetcher
    HTTP_TOO_MANY_REQUESTS = '429'

    attr_reader :gem_name

    # @param gem_name [String] name of the gem
    def initialize(gem_name)
      @gem_name = gem_name
    end

    # Finds the changelog uri.
    # It asks rubygems.org for changelog_uri of gem.
    # See API: http://guides.rubygems.org/rubygems-org-api/#gem-methods
    #
    # @return [String|nil] uri of changelog
    def changelog_uri
      response = query_rubygems
      response.to_h['changelog_uri']
    end

    private

    # Parse JSON from a remote url.
    #
    # @param url [String] remote url
    # @return [Hash] parsed JSON
    def parse_remote_json(url)
      JSON.parse(URI.parse(url).open.read)
    end

    # Make the real query to rubygems
    # It may fail in case we trigger too many requests
    #
    # @param tries [Integer|nil] (optional) how many times we tried
    def query_rubygems(tries = 0)
      parse_remote_json("https://rubygems.org/api/v1/gems/#{gem_name}.json")
    rescue OpenURI::HTTPError => e
      # We may trigger too many requests, in which case give rubygems a break
      if e.io.status.include?(HTTP_TOO_MANY_REQUESTS)
        tries += 1
        sleep 1 && retry if tries < 2
      end
    end
  end
end
