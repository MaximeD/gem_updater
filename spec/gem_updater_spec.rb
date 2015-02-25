require 'spec_helper'

describe GemUpdater::Updater do
  let( :gemfile ){ OpenStruct.new( update!: true, changes: [] ) }

  before :each do
    allow( GemUpdater::GemFile ).to receive( :new ).and_return( gemfile )
  end

  describe '#update' do
    before :each do
      allow( gemfile ).to receive( :update! )
      allow( gemfile ).to receive( :changes ).and_return( { fake_gem: { versions: { old: '0.1', new: '0.2' } } } )
      allow( GemUpdater::RubyGemsFetcher ).to receive_message_chain( :new, :source_uri )
      allow( GemUpdater::SourcePageParser ).to receive( :new ).and_return( @source_page = OpenStruct.new( changelog: 'fake_gem_changelog_url' ) )
      subject.update!
    end

    it 'updates gemfile' do
      expect( gemfile ).to have_received( :update! )
    end

    it 'gets changelogs' do
      expect( gemfile.changes[ :fake_gem ][ :changelog ] ).to eq 'fake_gem_changelog_url'
    end
  end

  describe '#format_diff' do
    before :each do
      allow( gemfile ).to receive( :changes ).and_return( {
        fake_gem_1: { changelog: 'fake_gem_1_url', versions: { old: '1.0', new: '1.1' } },
        fake_gem_2: { changelog: 'fake_gem_2_url', versions: { old: '0.4', new: '0.4.2' } }
      } )
      allow( STDOUT ).to receive( :puts )
      subject.format_diff
    end

    it 'outputs changes' do
      expect( STDOUT ).to have_received( :puts ).with( <<CHANGELOG
* fake_gem_1 1.0 → 1.1
[changelog](fake_gem_1_url)

CHANGELOG
      )

      expect( STDOUT ).to have_received( :puts ).with( <<CHANGELOG
* fake_gem_2 0.4 → 0.4.2
[changelog](fake_gem_2_url)

CHANGELOG
      )
    end
  end
end
