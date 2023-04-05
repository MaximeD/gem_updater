# frozen_string_literal: true

require 'erb'
require 'memoist'
require 'gem_updater/gem_file'
require 'gem_updater/ruby_gems_fetcher'
require 'gem_updater/source_page_parser'

# Base lib.
module GemUpdater
  # Updater's main responsability is to fill changes
  # happened before and after update of `Gemfile`, and then format them.
  class Updater
    extend Memoist

    attr_accessor :gemfile

    def initialize
      @gemfile = GemUpdater::GemFile.new
    end

    # Update process.
    # This will:
    #   1. update gemfile
    #   2. find changelogs for updated gems
    #
    # @param gems [Array] list of gems to update
    def update!(gems)
      gemfile.update!(gems)
      gemfile.compute_changes

      fill_changelogs
    end

    # Print formatted diff
    def output_diff
      Bundler.ui.info format_diff.join
    end

    # Format the diff to get human readable information
    # on the gems that were updated.
    def format_diff
      erb = ERB.new(template.force_encoding('UTF-8'), trim_mode: '<>')

      gemfile.changes.map do |gem, details|
        erb.result(binding)
      end
    end

    private

    # For each gem, retrieve its changelog
    def fill_changelogs
      [].tap do |threads|
        gemfile.changes.each do |gem_name, details|
          threads << Thread.new { retrieve_gem_changes(gem_name, details) }
        end
      end.each(&:join)
    end

    # Find where is hosted the source of a gem
    #
    # @param gem [String] the name of the gem
    # @param source [Bundler::Source] gem's source
    # @return [String] url where gem is hosted
    def find_source(gem, source)
      case source
      when Bundler::Source::Rubygems
        GemUpdater::RubyGemsFetcher.new(gem, source).source_uri
      when Bundler::Source::Git
        source.uri.gsub(/^git/, 'http').chomp('.git')
      end
    end

    def retrieve_gem_changes(gem_name, details)
      source_uri = find_source(gem_name, details[:source])
      return unless source_uri

      source_page = GemUpdater::SourcePageParser.new(
        url: source_uri, version: details[:versions][:new]
      )

      gemfile.changes[gem_name][:changelog] = source_page.changelog if source_page.changelog
    end

    # Get the template for gem's diff.
    # It can use a custom template.
    #
    # @return [ERB] the template
    def template
      File.read("#{Dir.home}/.gem_updater_template.erb")
    rescue Errno::ENOENT
      File.read(File.expand_path('../lib/gem_updater_template.erb', __dir__))
    end
    memoize :template
  end
end
