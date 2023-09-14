# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'gem_updater/changelog_parser/github_parser'

module GemUpdater
  # ChangelogParser is responsible for parsing a source page where
  # the gem code is hosted.
  class ChangelogParser
    MARKUP_FILES = %w[.md .rdoc .textile].freeze

    attr_reader :uri, :version

    # @param uri [String] uri of changelog
    # @param version [String] version of gem
    def initialize(uri:, version:)
      @uri     = uri
      @version = version
    end

    # Get the changelog in an uri.
    #
    # @return [String, nil] URL of changelog
    def changelog
      return uri unless changelog_may_contain_anchor?

      parse_changelog
    rescue OpenURI::HTTPError # Uri points to nothing
      log_error_and_return_uri("Cannot find #{uri}")
    rescue Errno::ETIMEDOUT # timeout
      log_error_and_return_uri("#{URI.parse(uri).host} is down")
    rescue ArgumentError => e # x-oauth-basic raises userinfo not supported. [RFC3986]
      log_error_and_return_uri(e)
    end

    private

    # Try to find where changelog might be.
    #
    # @param doc [Nokogiri::XML::Element] document of source page
    def parse_changelog
      case URI.parse(uri).host
      when 'github.com'
        GithubParser.new(uri: uri, version: version).changelog
      else
        uri
      end
    end

    # Some documents like the one written in markdown may contain
    # a direct anchor to specific version.
    #
    # @return [Boolean] true if file may contain an anchor
    def changelog_may_contain_anchor?
      MARKUP_FILES.include?(File.extname(uri.to_s))
    end

    def log_error_and_return_uri(error_message)
      Bundler.ui.error error_message
      uri
    end
  end
end
