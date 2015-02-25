require 'spec_helper'

describe GemUpdater::GemFile do
  subject( :gemfile ) { GemUpdater::GemFile.new }
  let( :bundler_cli ){ OpenStruct.new( update: true, compute_changes: true ) }

  def old_gem_set
    Bundler::SpecSet.new( [
      Gem::Specification.new( 'gem_up_to_date', '0.1' ),
      Gem::Specification.new( 'gem_to_update', '1.5' )
    ] )
  end

  def new_gem_set
    Bundler::SpecSet.new( [
      Gem::Specification.new( 'gem_up_to_date', '0.1' ),
      Gem::Specification.new( 'gem_to_update', '2.3' )
    ] )
  end

  before do
    allow( Bundler.definition ).to receive( :specs ).and_return( old_gem_set )
    allow( Bundler::CLI ).to receive( :new ).and_return( bundler_cli )
    allow( bundler_cli ).to receive( :update )
  end

  describe '#initialize' do
    before { subject }
    it 'gets current spec set' do
      expect( Bundler.definition ).to have_received( :specs )
    end
  end

  describe '#update!' do
    before :each do
      allow( subject ).to receive( :compute_changes )
      subject.update!
    end

    it 'launched bundle update' do
      expect( bundler_cli ).to have_received( :update )
    end

    it 'computes changes' do
      expect( subject ).to have_received( :compute_changes )
    end

    it 'gets new spec set' do
      expect( Bundler.definition ).to have_received( :specs ).twice
    end
  end

  describe '#compute_changes' do
    before :each do
      subject
      allow( Bundler.definition ).to receive( :specs ).and_return( new_gem_set )
      subject.update!
      subject.compute_changes
    end

    it 'skips gems that were not updated' do
      expect( subject.changes ).to_not have_key( :gem_up_to_date )
    end

    it 'includes updated gems with old and new version number' do
      expect( subject.changes[ 'gem_to_update' ] ).to eq( versions: { old: '1.5', new: '2.3' } )
    end
  end
end
