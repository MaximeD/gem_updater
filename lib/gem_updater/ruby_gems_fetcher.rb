# frozen_string_literal: true

require 'json'
require 'nokogiri'
require 'open-uri'

module GemUpdater
  # RubyGemsFetcher is a wrapper around rubygems API.
  class RubyGemsFetcher
    HTTP_TOO_MANY_REQUESTS = '429'
    GEM_HOMEPAGES = %w[source_code_uri homepage_uri].freeze

    attr_reader :gem_name, :source

    # @param gem_name [String] name of the gem
    # @param source [Bundler::Source] source of gem
    def initialize(gem_name, source)
      @gem_name = gem_name
      @source   = source
    end

    # Finds where code is hosted.
    # Most likely in will be on rubygems, else look in other sources.
    #
    # @return [String|nil] url of gem source code
    def source_uri
      uri_from_rubygems || uri_from_other_sources
    end

    private

    # Ask rubygems.org for source uri of gem.
    # See API: http://guides.rubygems.org/rubygems-org-api/#gem-methods
    #
    # @return [String|nil] uri of source code
    def uri_from_rubygems
      return unless source.remotes.map(&:host).include?('rubygems.org')

      response = query_rubygems
      return unless response

      response[GEM_HOMEPAGES.find { |key| response[key] && !response[key].empty? }]
    end

    # Make the real query to rubygems
    # It may fail in case we trigger too many requests
    #
    # @param tries [Integer|nil] (optional) how many times we tried
    def query_rubygems(tries = 0)
      JSON.parse(open("https://rubygems.org/api/v1/gems/#{gem_name}.json").read)
    rescue OpenURI::HTTPError => e
      # We may trigger too many requests, in which case give rubygems a break
      if e.io.status.include?(HTTP_TOO_MANY_REQUESTS)
        if (tries += 1) < 2
          sleep 1 && retry
        end
      end
    end

    # Look if gem can be found in another remote
    #
    # @return [String|nil] uri of source code
    # rubocop:disable Metrics/MethodLength
    def uri_from_other_sources
      uri = nil
      source.remotes.each do |remote|
        break if uri

        uri = case remote.host
              when 'rubygems.org' then next # already checked
              when 'rails-assets.org'
                uri_from_railsassets
              else
                Bundler.ui.error "Source #{remote} is not supported, ' \
                  'feel free to open a PR or an issue on https://github.com/MaximeD/gem_updater"
              end
      end

      uri
    end
    # rubocop:enable Metrics/MethodLength

    # Ask rails-assets.org for source uri of gem.
    # API is at : https://rails-assets.org/packages/package_name
    #
    # @return [String|nil] uri of source code
    def uri_from_railsassets
      response = query_railsassets
      return unless response

      response['url'].gsub(/^git/, 'http')
    end

    # Make the real query to railsassets
    # rubocop:disable Lint/SuppressedException
    def query_railsassets
      JSON.parse(
        open(
          "https://rails-assets.org/packages/#{gem_name.gsub(/rails-assets-/, '')}"
        ).read
      )
    rescue JSON::ParserError
      # if gem is not found, rails-assets returns a 200
      # with html (instead of json) containing a 500...
    rescue OpenURI::HTTPError
    end
    # rubocop:enable Lint/SuppressedException
  end
end
