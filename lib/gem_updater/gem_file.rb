require 'bundler/cli'

module GemUpdater

  # GemFile is responsible for handling `Gemfile`
  class GemFile
    attr_accessor :changes

    def initialize
      @old_spec_set = Bundler.definition.specs
      @changes      = {}
    end

    # Run `bundle update` to update gems.
    # Then get new spec set.
    def update!
      puts "Updating gems..."
      Bundler::CLI.start( [ 'update' ] )
      @new_spec_set = Bundler.definition.specs
      compute_changes
    end

    # Compute the diffs between two `Gemfile.lock`.
    #
    # @return [Hash] gems for which there are differences.
    def compute_changes
      @old_spec_set.each do |gem_specs|
        unless ( old_version = gem_specs.version ) == ( new_version = @new_spec_set[ gem_specs.name ].first.version )
          @changes[ gem_specs.name ] = { versions: { old: old_version.to_s, new: new_version.to_s } }
        end
      end
    end
  end
end
