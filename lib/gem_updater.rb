# frozen_string_literal: true

require 'erb'
require 'gem_updater/changelog_parser'
require 'gem_updater/gemfile'
require 'gem_updater/ruby_gems_fetcher'

# Base lib.
module GemUpdater
  # Updater's main responsability is to fill changes
  # happened before and after update of `Gemfile`, and then format them.
  class Updater
    RUBYGEMS_SOURCE_NAME = 'rubygems repository https://rubygems.org/'

    attr_accessor :gemfile

    def initialize
      @gemfile = GemUpdater::Gemfile.new
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
        gemfile.changes.each do |gem_changes, details|
          threads << Thread.new { retrieve_changelog(gem_changes, details) }
        end
      end.each(&:join)
    end

    # Get the changelog URL.
    def retrieve_changelog(gem_name, details)
      return unless details[:source].name == RUBYGEMS_SOURCE_NAME

      changelog_uri = RubyGemsFetcher.new(gem_name).changelog_uri

      return unless changelog_uri

      changelog = ChangelogParser
                  .new(uri: changelog_uri, version: details.dig(:versions, :new)).changelog
      gemfile.changes[gem_name][:changelog] = changelog&.to_s
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
  end
end
