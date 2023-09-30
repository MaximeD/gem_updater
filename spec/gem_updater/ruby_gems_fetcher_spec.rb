# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::RubyGemsFetcher do
  subject(:ruby_gems_fetcher) { described_class.new('gem_name') }

  let(:remote_response) { nil }

  describe '#changelog_uri' do
    subject(:changelog_uri) { ruby_gems_fetcher.changelog_uri }

    before do
      allow(URI).to receive_message_chain(:parse, :open, :read).and_return(remote_response.to_json)
    end

    context 'when gem exists on rubygems.org' do
      context "when 'changelog_uri' is present" do
        let(:remote_response) { { changelog_uri: 'some_uri' } }

        it "returns 'changelog_uri' value" do
          expect(changelog_uri).to eq 'some_uri'
        end
      end

      context "when 'changelog_uri' is absent" do
        let(:remote_response) { {} }

        it { is_expected.to be_nil }
      end

      context 'when making too many requests' do
        before do
          allow(ruby_gems_fetcher).to receive(:sleep)
          allow(ruby_gems_fetcher).to receive(:parse_remote_json)
            .and_raise(OpenURI::HTTPError.new('429', double(status: ['429'])))
        end

        it 'tries again' do
          changelog_uri
          expect(ruby_gems_fetcher).to have_received(:parse_remote_json).twice
        end
      end
    end
  end
end
