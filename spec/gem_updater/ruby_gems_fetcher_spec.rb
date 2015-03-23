require 'spec_helper'

describe GemUpdater::RubyGemsFetcher do
  subject { GemUpdater::RubyGemsFetcher.new( 'gem_name', OpenStruct.new( remotes: [ URI( 'https://rubygems.org' ) ] ) ) }

  describe '#source_uri' do
    context 'when gem exists on rubygems.org' do
      context "when 'source_code_uri' is present" do
        before do
          allow( subject ).to receive_message_chain( :open, :read ) { { source_code_uri: 'source_code_uri' }.to_json }
          subject.source_uri
        end

        it "returns 'source_code_uri' value" do
          expect( subject.source_uri ).to eq 'source_code_uri'
        end
      end

      context "when 'homepage_uri' is present" do
        before do
          allow( subject ).to receive_message_chain( :open, :read ) { { homepage_uri: 'homepage_uri' }.to_json }
          subject.source_uri
        end

        it "returns 'homepage_uri' value" do
          expect( subject.source_uri ).to eq 'homepage_uri'
        end
      end

      context "when both 'source_code_uri' and 'homepage_uri' are present" do
        before do
          allow( subject ).to receive_message_chain( :open, :read ) { { source_code_uri: 'source_code_uri', homepage_uri: 'homepage_uri' }.to_json }
          subject.source_uri
        end

        it "returns 'source_code_uri' value" do
          expect( subject.source_uri ).to eq 'source_code_uri'
        end
      end

      context 'none is present' do
        before do
          allow( subject ).to receive_message_chain( :open, :read ) { {}.to_json }
          allow( subject ).to receive( :uri_from_other_sources )
          subject.source_uri
        end

        it 'looks in other sources' do
          expect( subject ).to have_received( :uri_from_other_sources )
        end
      end
    end

    context 'when gem does not exists on rubygems.org' do
      context 'when they are no other hosts' do
        before :each do
          allow( subject ).to receive( :uri_from_rubygems ) { nil }
        end

        it 'returns nil' do
          expect( subject.source_uri ).to be_nil
        end
      end

      context 'when they are other hosts' do
        before :each do
          allow( subject ).to receive( :uri_from_rubygems ) { nil }
        end

        describe 'looking on rubygems' do
          before :each do
            allow( subject.source ).to receive( :remotes ) { [ URI( 'https://rubygems.org' ), URI( '' ) ] }
            allow( subject ).to receive( :uri_from_other_sources ) { nil }
            subject.source_uri
          end

          it 'does it only once' do
            expect( subject ).to have_received( :uri_from_rubygems ).once
          end
        end

        context 'when gem can be hosted on rails-assets.org' do
          before :each do
            allow( subject.source ).to receive( :remotes ) { [ URI( 'https://rubygems.org' ), URI( 'https://rails-assets.org' ) ] }
          end

          context 'when gem is on rails-assets' do
            before :each do
              allow( subject ).to receive_message_chain( :open, :read ) { { url: 'git://fake.com/gem_name' }.to_json }
            end

            it 'returns http url' do
              expect( subject.source_uri ).to eq 'http://fake.com/gem_name'
            end
          end

          context 'when gem is not on rails-assets' do
            before :each do
              allow( subject ).to receive_message_chain( :open, :read ) { "<title>We're sorry, but something went wrong (500)</title>" }
            end

            it 'returns nil' do
              expect( subject.source_uri ).to be_nil
            end
          end
        end
      end
    end
  end
end
