# frozen_string_literal: true

require 'bundler/cli'

module GemUpdater
  # GemFile is responsible for handling `Gemfile`
  class GemFile
    attr_accessor :changes
    attr_reader :old_spec_set, :new_spec_set

    def initialize
      @changes = {}
    end

    # Run `bundle update` to update gems.
    def update!(gems)
      Bundler.ui.warn 'Updating gems...'
      Bundler::CLI.start(['update'] + gems)
    end

    # Compute the diffs between two `Gemfile.lock`.
    #
    # @return [Hash] gems for which there are differences.
    def compute_changes
      spec_sets_diff!

      old_spec_set.each do |old_gem|
        updated_gem = new_spec_set.find { |new_gem| new_gem.name == old_gem.name }
        next unless updated_gem && old_gem.version != updated_gem.version

        fill_changes(old_gem, updated_gem)
      end
    end

    private

    # Get the two spec sets (before and after `bundle update`)
    def spec_sets_diff!
      @old_spec_set = spec_set
      reinitialize_spec_set!
      @new_spec_set = spec_set
    end

    # Get the current spec set
    #
    # @return [Array] array of Bundler::LazySpecification (including gem name, version and source)
    def spec_set
      Bundler.locked_gems.specs
    end

    # Calling `Bundler.locked_gems` before or after a `bundler update`
    # will return the same result.
    # Use a hacky way to tell bundle we want to parse the new `Gemfile.lock`
    def reinitialize_spec_set!
      Bundler.remove_instance_variable('@locked_gems')
      Bundler.remove_instance_variable('@definition')
    end

    # Add changes to between two versions of a gem
    #
    # @param old_gem [Bundler::LazySpecification]
    # @param new_gem [Bundler::LazySpecification]
    def fill_changes(old_gem, updated_gem)
      changes[old_gem.name] = {
        versions: {
          old: old_gem.version.to_s, new: updated_gem.version.to_s
        },
        source: updated_gem.source
      }
    end
  end
end
