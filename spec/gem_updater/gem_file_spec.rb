require 'spec_helper'

describe GemUpdater::GemFile do
  subject( :gemfile ) { GemUpdater::GemFile.new }
  let( :old_spec_set ) do
    [
      Bundler::LazySpecification.new( 'gem_up_to_date', '0.1', 'ruby', 'gem_up_to_date_source' ),
      Bundler::LazySpecification.new( 'gem_to_update', '1.5', 'ruby', 'gem_to_update_source' )
    ]
  end

  let( :new_spec_set ) do
    [
      Bundler::LazySpecification.new( 'gem_up_to_date', '0.1', 'ruby', 'gem_up_to_date_source' ),
      Bundler::LazySpecification.new( 'gem_to_update', '2.3', 'ruby', 'gem_to_update_source' )
    ]
  end

  before do
    allow( Bundler ).to receive_message_chain( :locked_gems, :specs ) { old_spec_set }
    allow( Bundler::CLI ).to receive( :start )
  end

  describe '#update!' do
    before :each do
      allow( subject ).to receive( :compute_changes )
      subject.update!
    end

    it 'launches bundle update' do
      expect( Bundler::CLI ).to have_received( :start ).with( [ 'update' ] )
    end
  end

  describe '#compute_changes' do
    before :each do
      allow( subject ).to receive( :get_spec_sets )
      allow( subject ).to receive( :old_spec_set )  { old_spec_set }
      allow( subject ).to receive( :new_spec_set )  { new_spec_set }
      subject.compute_changes
    end

    it 'gets specs sets' do
      expect( subject ).to have_received( :get_spec_sets )
    end

    it 'skips gems that were not updated' do
      expect( subject.changes ).to_not have_key( :gem_up_to_date )
    end

    it 'includes updated gems with old and new version number' do
      expect( subject.changes[ 'gem_to_update' ] ).to eq( versions: { old: '1.5', new: '2.3' }, source: 'gem_to_update_source' )
    end
  end


  describe '#get_spec_sets' do
    before :each do
      allow( subject ).to receive( :reinitialize_spec_set! )
      subject.send( :get_spec_sets )
    end

    it 'gets specs spet' do
      expect( Bundler.locked_gems ).to have_received( :specs ).twice
    end
  end

  describe '#spec_set' do
    before :each do
      subject.send( :spec_set )
    end

    it 'calls Bundler.locked_gems.specs' do
      expect( Bundler ).to have_received( :locked_gems )
      expect( Bundler.locked_gems ).to have_received( :specs )
    end
  end

  describe '#reinitialize_spec_set!' do
    before :each do
      allow( Bundler ).to receive( :remove_instance_variable )
      subject.send( :reinitialize_spec_set! )
    end

    it 'reinitializes locked gems' do
      expect( Bundler ).to have_received( :remove_instance_variable ).with( "@locked_gems" )
    end
  end
end
