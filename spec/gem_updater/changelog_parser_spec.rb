# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::ChangelogParser do
  subject(:changelog_parser) { described_class.new(uri: uri, version: version) }

  let(:uri) { 'https://github.com/example/fake/changelog.md' }
  let(:version) { '1.2.1' }

  describe '#changelog' do
    context 'when changelog file does not support HTML anchor' do
      let(:uri) { 'https://github.com/example/fake/changelog.txt' }

      it 'returns the base uri' do
        expect(changelog_parser.changelog).to eq uri
      end
    end

    context 'when changelog file supports HTML anchor' do
      context 'when changelog is hosted on github' do
        let(:parser) { instance_double(described_class::GithubParser) }

        before do
          allow(described_class::GithubParser)
            .to receive(:new).with(uri: uri, version: version) { parser }
          allow(parser).to receive(:changelog) { 'https://github.com/example/fake/changelog.md#1.2.1' }
        end

        it 'returns parsed changelog' do
          expect(changelog_parser.changelog).to eq 'https://github.com/example/fake/changelog.md#1.2.1'
        end

        context 'when something goes wrong' do
          context 'when URI was not found' do
            before do
              allow(parser).to receive(:changelog)
                .and_raise(OpenURI::HTTPError.new(double, double))
            end

            it 'returns the base uri' do
              expect(changelog_parser.changelog).to eq uri
            end
          end

          context 'when request times out' do
            before do
              allow(parser).to receive(:changelog)
                .and_raise(Errno::ETIMEDOUT)
            end

            it 'returns the base uri' do
              expect(changelog_parser.changelog).to eq uri
            end
          end

          context 'when request needs authentication' do
            before do
              allow(parser).to receive(:changelog)
                .and_raise(ArgumentError, 'userinfo not supported. [RFC3986]')
            end

            it 'returns the base uri' do
              expect(changelog_parser.changelog).to eq uri
            end
          end
        end
      end

      context 'when changelog is not hosted on github' do
        let(:uri) { 'https://other_host.com/example/fake/changelog.md' }

        it 'returns the base uri' do
          expect(changelog_parser.changelog).to eq uri
        end
      end
    end
  end
end
