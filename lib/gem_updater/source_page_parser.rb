require 'nokogiri'
require 'open-uri'

module GemUpdater

  class SourcePageParser
    def initialize( url )
      @uri = correct_uri( url )
    end

    # Get the changelog in an uri.
    #
    # @return [Nokogiri::XML::Node]: the changelog
    def changelog
      @changelog ||= begin
       puts "Looking for a changelog in #{@uri}"
       doc = Nokogiri::HTML(open( @uri ) )

       changelog = find_changelog( doc )

       # Uri points to nothing
      rescue OpenURI::HTTPError # Uri points to nothing
       puts "Cannot find #{@uri}"
      end
    end

    private

    # Some gems have 'http://github.com' as URI which will redirect to https
    # leading `open_uri` to crash.
    #
    # @param [String]: url to parse
    # @return [URI]: valid URI
    def correct_uri( url )
      uri = URI( url )
      uri.scheme = 'https' if uri.host == 'github.com' && uri.scheme == 'http'

      uri
    end

    # Try to find where changelog might be.
    # Since humans can have many many ways to reference it,
    # it will do it's best to find the good one.
    #
    # @param [Nokogiri::XML::Node]: the document to parse.
    def find_changelog( doc )
      names = %w( CHANGELOG Changelog ChangeLog HISTORY History history )
      node = nil

      names.each do |name|
        break if node = doc.at_css( %(table.files a[title^="#{name}"]) )
      end

      node
    end
  end
end
