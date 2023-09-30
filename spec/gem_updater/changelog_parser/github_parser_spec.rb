# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::ChangelogParser::GithubParser do
  subject(:parser) { described_class.new(uri: uri, version: version) }

  describe '#changelog' do
    context 'when changelog contains an anchor',
            vcr: { cassette_name: 'changelog_parser/github_parser/with_anchor' } do
      let(:uri) { 'https://github.com/puma/puma/blob/master/History.md' }
      let(:version) { '6.3.0' }

      it 'returns the changelog with the anchor' do
        expect(parser.changelog).to eq 'https://github.com/puma/puma/blob/master/History.md#630--2023-05-31'
      end
    end

    context 'when changelog does not contain an anchor',
            vcr: { cassette_name: 'changelog_parser/github_parser/without_anchor' } do
      let(:uri) { 'https://github.com/camping/camping/blob/main/CHANGELOG' }
      let(:version) { '3.0.2' }

      it 'returns the changelog' do
        expect(parser.changelog).to eq 'https://github.com/camping/camping/blob/main/CHANGELOG'
      end
    end

    context 'when something goes wrong opening the changelog',
            vcr: { cassette_name: 'changelog_parser/github_parser/not_found' } do
      let(:uri) { 'https://github.com/example/fake/blob/master/CHANGELOG.md' }
      let(:version) { '1.0.0' }

      it 'raises an error' do
        expect { parser.changelog }.to raise_error OpenURI::HTTPError
      end
    end
  end
end
