require 'gem_updater/gem_file'
require 'gem_updater/ruby_gems_fetcher'
require 'gem_updater/source_page_parser'

module GemUpdater
  class Updater

    def initialize
      @gemfile = GemUpdater::GemFile.new
    end

    # Update process.
    # This will:
    #   1. update gemfile
    #   2. find changelogs for updated gems
    def update!
      @gemfile.update!

      @gemfile.changes.each do |gem_name, details|
        source_uri  = GemUpdater::RubyGemsFetcher.new( gem_name ).source_uri
        source_page = GemUpdater::SourcePageParser.new( url: source_uri, version: details[ :versions ][ :new ] )

        @gemfile.changes[ gem_name ][ :changelog ] = source_page.changelog if source_page.changelog
      end
    end

    # Format the diff to get human readable information
    # on the gems that were updated.
    def format_diff
      @gemfile.changes.each do |gem, details|
        puts ERB.new( template, nil, '<>' ).result( binding )
      end
    end

    private

    # Get the template for gem's diff.
    # It can use a custom template.
    #
    # @return [ERB] the template
    def template
      @template ||= begin
        File.read( "#{Dir.home}/.gem_updater_template.erb" )
      rescue Errno::ENOENT
        File.read( File.expand_path( '../../lib/gem_updater_template.erb', __FILE__ ) )
      end
    end
  end
end
