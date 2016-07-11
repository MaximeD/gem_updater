require 'nokogiri'
require 'open-uri'

module GemUpdater

  # SourcePageParser is responsible for parsing a source page where
  # the gem code is hosted.
  class SourcePageParser
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
      @changelog ||= begin
        if uri
          Bundler.ui.warn "Looking for a changelog in #{uri}"
          doc = Nokogiri::HTML(open(uri))

          find_changelog(doc)
        end

      rescue OpenURI::HTTPError # Uri points to nothing
        Bundler.ui.error "Cannot find #{uri}"
        false
      rescue Errno::ETIMEDOUT # timeout
        Bundler.ui.error "#{uri} is down"
        false
      end
    end

    private

    # Some gems have 'http://github.com' as URI which will redirect to https
    # leading `open_uri` to crash.
    #
    # @param url [String] the url to parse
    # @return [URI] valid URI
    def correct_uri(url)
      return unless String === url && !url.empty?

      uri = URI(url)

      if uri.scheme == 'http'
        known_https(uri)
      else
        uri
      end
    end

    # Some uris are not https, but we know they should be,
    # in which case we have an https redirection
    # which is not properly handled by open-uri
    #
    # @param uri [URI::HTTP]
    # @return [URI::HTTPS|URI::HTTP]
    def known_https(uri)
      case
      when uri.host =~ HOSTS[:github]
        # remove possible subdomain like 'wiki.github.com'
        URI "https://github.com#{uri.path}"
      when uri.host =~ HOSTS[:bitbucket]
        URI "https://#{uri.host}#{uri.path}"
      when uri.host =~ HOSTS[:rubygems]
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

    # GitHubParser is responsible for parsing source code
    # hosted on github.com.
    class GitHubParser < SourcePageParser
      BASE_URL = 'https://github.com'.freeze

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

        if url
          full_url = BASE_URL + url

          if changelog_may_contain_anchor?(full_url)
            anchor = find_anchor(full_url)
            full_url += anchor if anchor
          end

          full_url
        end
      end

      private

      # Find which link corresponds to changelog.
      #
      # @return [String, nil] url of changelog
      def find_changelog_link
        changelog_names.find do |name|
          node = doc.at_css(%(table.files .content a[title^="#{name}"]))

          break node.attr('href') if node
        end
      end

      # Looks into document to find it there is an anchor to new gem version.
      #
      # @param url [String] url of changelog
      # @return [String, nil] anchor's href
      def find_anchor(url)
        changelog_page = Nokogiri::HTML(open(url))
        anchor = changelog_page.css(%(a.anchor)).find do |element|
          element.attr('href').match(version.delete('.'))
        end

        anchor.attr('href') if anchor
      end
    end
  end
end
