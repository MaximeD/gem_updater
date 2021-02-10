# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::RubyGemsFetcher do
  subject(:ruby_gems_fetcher) do
    GemUpdater::RubyGemsFetcher.new(
      'gem_name',
      OpenStruct.new(remotes: remotes)
    )
  end

  let!(:remotes) { [URI('https://rubygems.org')] }
  let(:remote_response) { nil }

  describe '#source_uri' do
    subject(:source_uri) { ruby_gems_fetcher.source_uri }

    before do
      allow(URI).to receive_message_chain(:parse, :open, :read).and_return(remote_response.to_json)
    end

    context 'when gem exists on rubygems.org' do
      describe 'making too many requests' do
        before do
          allow(ruby_gems_fetcher).to receive(:sleep)
          allow(ruby_gems_fetcher).to receive(:parse_remote_json)
            .and_raise(OpenURI::HTTPError.new('429', OpenStruct.new(status: ['429'])))
        end

        it 'tries again' do
          source_uri
          expect(ruby_gems_fetcher).to have_received(:parse_remote_json).twice
        end
      end

      context "when 'source_code_uri' is present" do
        let(:remote_response) { { source_code_uri: 'source_code_uri' } }

        it "returns 'source_code_uri' value" do
          expect(source_uri).to eq 'source_code_uri'
        end
      end

      context "when 'homepage_uri' is present" do
        let(:remote_response) { { homepage_uri: 'homepage_uri' } }

        it "returns 'homepage_uri' value" do
          expect(source_uri).to eq 'homepage_uri'
        end
      end

      context "when both 'source_code_uri' and 'homepage_uri' are present" do
        let(:remote_response) do
          {
            source_code_uri: 'source_code_uri',
            homepage_uri: 'homepage_uri'
          }
        end

        it "returns 'source_code_uri' value" do
          expect(source_uri).to eq 'source_code_uri'
        end
      end

      context 'when none is present' do
        let(:remote_response) { {} }

        it 'looks in other sources' do
          expect(ruby_gems_fetcher).to receive(:uri_from_other_sources)
          source_uri
        end
      end

      context 'when both returns empty string' do
        let(:remote_response) do
          {
            source_code_uri: '',
            homepage_uri: ''
          }
        end

        it 'looks in other sources' do
          expect(ruby_gems_fetcher).to receive(:uri_from_other_sources)
          source_uri
        end
      end
    end

    context 'when gem does not exists on rubygems.org' do
      context 'when there are no other hosts' do
        it 'returns nil' do
          expect(source_uri).to be_nil
        end
      end

      context 'when there are other hosts' do
        let(:remotes) { [URI('https://rubygems.org'), URI('https://rails-assets.org')] }

        describe 'looking on rubygems' do
          it 'does it only once' do
            expect(ruby_gems_fetcher).to receive(:uri_from_rubygems).once
            source_uri
          end
        end

        context 'when gem can be hosted on rails-assets.org' do
          let(:remotes) { [URI('https://rails-assets.org')] }
          let(:remote_response) { { url: 'git://fake.com/gem_name' } }

          context 'when gem is on rails-assets' do
            it 'returns http url' do
              expect(source_uri).to eq 'http://fake.com/gem_name'
            end
          end

          context 'when gem is not on rails-assets' do
            before do
              allow(URI).to receive_message_chain(:parse, :open, :read).and_return(
                "<title>We're sorry, but something went wrong (500)</title>"
              )
            end

            it 'returns nil' do
              expect(source_uri).to be_nil
            end
          end
        end
      end
    end
  end
end
