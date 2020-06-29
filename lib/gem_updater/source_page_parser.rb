# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

module GemUpdater
  # SourcePageParser is responsible for parsing a source page where
  # the gem code is hosted.
  class SourcePageParser
    extend Memoist

    HOSTS = {
      github: /github.com/,
      bitbucket: /bitbucket.org/,
      rubygems: /rubygems.org/
    }.freeze
    MARKUP_FILES = %w[.md .rdoc .textile].freeze
    CHANGELOG_NAMES = %w[changelog ChangeLog history changes news].freeze

    attr_reader :uri, :version

    # @param url [String] url of page
    # @param version [String] version of gem
    def initialize(url: nil, version: nil)
      @uri     = correct_uri(url)
      @version = version
    end

    # Get the changelog in an uri.
    #
    # @return [String, nil] URL of changelog
    def changelog
      return unless uri

      Bundler.ui.warn "Looking for a changelog in #{uri}"
      find_changelog(Nokogiri::HTML(URI.open(uri)))
    rescue OpenURI::HTTPError # Uri points to nothing
      log_error("Cannot find #{uri}")
    rescue Errno::ETIMEDOUT # timeout
      log_error("#{uri} is down")
    rescue ArgumentError => e # x-oauth-basic raises userinfo not supported. [RFC3986]
      log_error(e)
    end
    memoize :changelog

    private

    # Some gems have 'http://github.com' as URI which will redirect to https
    # leading `open_uri` to crash.
    #
    # @param url [String] the url to parse
    # @return [URI] valid URI
    def correct_uri(url)
      return unless url.is_a?(String) && !url.empty?

      uri = URI(url)
      uri.scheme == 'http' ? known_https(uri) : uri
    end

    # Some uris are not https, but we know they should be,
    # in which case we have an https redirection
    # which is not properly handled by open-uri
    #
    # @param uri [URI::HTTP]
    # @return [URI::HTTPS|URI::HTTP]
    def known_https(uri)
      case uri.host
      when HOSTS[:github]
        # remove possible subdomain like 'wiki.github.com'
        URI "https://github.com#{uri.path}"
      when HOSTS[:bitbucket]
        URI "https://#{uri.host}#{uri.path}"
      when HOSTS[:rubygems]
        URI "https://#{uri.host}#{uri.path}"
      else
        uri
      end
    end

    # Try to find where changelog might be.
    #
    # @param doc [Nokogiri::XML::Element] document of source page
    def find_changelog(doc)
      case uri.host
      when 'github.com'
        GitHubParser.new(doc, version).changelog
      end
    end

    # List possible names for a changelog
    # since humans may have many many ways to call it.
    #
    # @return [Array] list of possible names
    def changelog_names
      CHANGELOG_NAMES.flat_map do |name|
        [name, name.upcase, name.capitalize]
      end.uniq
    end

    # Some documents like the one written in markdown may contain
    # a direct anchor to specific version.
    #
    # @param file_name [String] file name of changelog
    # @return [Boolean] true if file may contain an anchor
    def changelog_may_contain_anchor?(file_name)
      MARKUP_FILES.include?(File.extname(file_name))
    end

    def log_error(error_message)
      Bundler.ui.error error_message
      false
    end

    # GitHubParser is responsible for parsing source code
    # hosted on github.com.
    class GitHubParser < SourcePageParser
      BASE_URL = 'https://github.com'

      attr_reader :doc, :version

      # @param doc [Nokogiri::XML::Element] document of source page
      # @param version [String] version of gem
      def initialize(doc, version)
        @doc     = doc
        @version = version
      end

      # Finds url of changelog.
      #
      # @return [String] the URL of changelog
      def changelog
        url = find_changelog_link
        return unless url

        full_url = BASE_URL + url

        if changelog_may_contain_anchor?(full_url)
          anchor = find_anchor(full_url)
          full_url += anchor if anchor
        end

        full_url
      end

      private

      # Find which link corresponds to changelog.
      #
      # @return [String, nil] url of changelog
      def find_changelog_link
        changelog_names.find do |name|
          node = doc.at_css(%([aria-labelledby="files"] a[title^="#{name}"]))

          break node.attr('href') if node
        end
      end

      # Looks into document to find it there is an anchor to new gem version.
      #
      # @param url [String] url of changelog
      # @return [String, nil] anchor's href
      def find_anchor(url)
        changelog_page = Nokogiri::HTML(URI.open(url))
        anchor = changelog_page.css(%(a.anchor)).find do |element|
          element.attr('href').match(version.delete('.'))
        end

        anchor&.attr('href')
      end
    end
  end
end
