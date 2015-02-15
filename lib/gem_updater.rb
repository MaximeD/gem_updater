require 'gem_updater/gem_file'
require 'gem_updater/ruby_gems_fetcher'
require 'gem_updater/source_page_parser'

module GemUpdater
  class Updater

    def initialize
      @gemfile = GemUpdater::GemFile.new
    end

    def update!
      @gemfile.update!

      @gemfile.changes.each do |gem_name, _|
        source_uri  = GemUpdater::RubyGemsFetcher.new( gem_name ).source_uri
        source_page = GemUpdater::SourcePageParser.new( source_uri )

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
  end
end

gems = GemUpdater::Updater.new
gems.update!
gems.format_diff
