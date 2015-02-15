require 'json'
require 'nokogiri'
require 'open-uri'

module GemUpdater
  class RubyGemsFetcher

    def initialize( gem_name )
      @gem_name = gem_name
    end

    # Finds where code is hosted.
    # Most likely in will be in 'source_code_uri' or 'homepage_uri'
    #
    # @return [String]: url of gem source code
    def source_uri
      information[ "source_code_uri" ] || information[ "homepage_uri" ]
    end

    private

    # Obtain information about a given gem
    # from rubygems.org.
    # See API: http://guides.rubygems.org/rubygems-org-api/#gem-methods
    #
    # @return [String]: json formatted information.
    def information
      @information ||= JSON.parse( open( "https://rubygems.org/api/v1/gems/#{@gem_name}.json" ).read )
    end
  end
end
