require 'git'
require 'pry'
require 'json'
require 'bundler/cli'

require 'open-uri'
require 'nokogiri'

# BRANCH_NAME = 'update_gems'
# git = Git.open( Dir.pwd )
#
# git.branch( BRANCH_NAME ).checkout

class GemUpdater

  def initialize
    @gemfile = GemFile.new
  end

  def update!
    @gemfile.update!

    @gemfile.changes.each do |gem_name, _|
      source_uri  = RubyGemsParser.new( gem_name ).source_uri
      source_page = SourcePageParser.new( source_uri )

      if source_page.changelog
        @gemfile.changes[ gem_name ][ :changelog ] = "https://github.com#{source_page.changelog.attr( 'href' )}"
      end
    end

    # Format the diff to get human readable information
    # on the gems that were updated.
    def format_diff
      @gemfile.changes.each do |gem, details|
        puts "* #{gem} #{details[ :versions ][ :old ]} → #{details[ :versions ][ :new ]}"
        puts "[changelog](#{details[ :changelog ]})" if details[ :changelog ]
        puts
      end
    end
  end

  class GemFile
    attr_accessor :changes

    def initialize
      @old_spec_set = Bundler.definition.specs
      @changes      = {}
    end

    # Run bundle update to update gems.
    # Then get new spec set.
    def update!
      puts "Updating gems..."
      Bundler::CLI.new.update # FIXME this raises error (this is just warnings though).
      @new_spec_set = Bundler.definition.specs
      compute_changes
    end

    # Compute the diffs between two `Gemfile.lock`.
    #
    # @return [Hash]: gems for which there are differences.
    def compute_changes
      @old_spec_set.each do |gem_specs|
        unless ( old_version = gem_specs.version ) == ( new_version = @new_spec_set[ gem_specs.name ].first.version )
          @changes[ gem_specs.name ] = { versions: { old: old_version.to_s, new: new_version.to_s } }
        end
      end
    end
  end

  class RubyGemsParser

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
      names = %w( CHANGELOG Changelog ChangeLog HISTORY History )
      node = nil

      names.each do |name|
        break if node = doc.at_css( %(table.files a[title^="#{name}"]) )
      end

      node
    end
  end
end

gems = GemUpdater.new
gems.update!
gems.format_diff
