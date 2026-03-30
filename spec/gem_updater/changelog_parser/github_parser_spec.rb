# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::ChangelogParser::GithubParser do
  let(:raw_content_url) { 'https://raw.githubusercontent.com/owner/repo/main/CHANGELOG.md' }

  describe '#changelog' do
    def stub_content(content)
      allow(URI).to receive(:parse).with(raw_content_url).and_return(double(read: content))
    end

    def stub_requests(content)
      allow(subject).to receive(:raw_content_url).and_return(raw_content_url)
      stub_content(content)
    end

    context 'when anchor is found' do
      subject { described_class.new(uri: 'https://github.com/repo/blob/main/CHANGELOG.md', version: version) }

      context 'with version and date format' do
        let(:version) { '6.3.0' }
        let(:content) { "## 6.3.0 / 2023-05-31\n" }

        before { stub_requests(content) }

        it 'returns URL with anchor' do
          expect(subject.changelog).to eq 'https://github.com/repo/blob/main/CHANGELOG.md#630--2023-05-31'
        end
      end

      context 'with date and parentheses format' do
        let(:version) { '2.19.3' }
        let(:content) { "## 2026-03-25 (2.19.3)\n" }

        before { stub_requests(content) }

        it 'returns URL with anchor' do
          expect(subject.changelog).to eq 'https://github.com/repo/blob/main/CHANGELOG.md#2026-03-25-2193'
        end
      end

      context 'with simple version format' do
        let(:version) { '5.0.0' }
        let(:content) { "## 5.0.0\n" }

        before { stub_requests(content) }

        it 'returns URL with anchor' do
          expect(subject.changelog).to eq 'https://github.com/repo/blob/main/CHANGELOG.md#500'
        end
      end

      context 'with RDoc format' do
        let(:version) { '6.0.2' }
        let(:content) { "=== 6.0.2 / 2026-02-23\n" }

        before { stub_requests(content) }

        it 'returns URL with anchor' do
          expect(subject.changelog).to eq 'https://github.com/repo/blob/main/CHANGELOG.md#602--2026-02-23'
        end
      end

      context 'with diacritics' do
        let(:version) { '2.11.3' }
        let(:content) { "## [2.11.3] - 2025-09-15 - Janosch Müller\n" }

        before { stub_requests(content) }

        it 'returns URL with anchor preserving diacritics' do
          expect(subject.changelog).to eq 'https://github.com/repo/blob/main/CHANGELOG.md#2113---2025-09-15---janosch-müller'
        end
      end
    end

    context 'when anchor is not found' do
      subject { described_class.new(uri: 'https://github.com/repo/blob/main/CHANGELOG.md', version: '3.0.2') }
      let(:content) { "## 3.0.1 / 2023-01-01\n" }

      before { stub_requests(content) }

      it 'returns base URL' do
        expect(subject.changelog).to eq 'https://github.com/repo/blob/main/CHANGELOG.md'
      end
    end

    context 'when request fails' do
      subject { described_class.new(uri: 'https://github.com/fake/blob/master/CHANGELOG.md', version: '1.0.0') }

      before do
        allow(URI).to receive(:parse).with(subject.uri).and_raise(OpenURI::HTTPError.new(
                                                                    'Not found', nil
                                                                  ))
      end

      it 'raises HTTPError' do
        expect { subject.changelog }.to raise_error OpenURI::HTTPError
      end
    end

    context 'when raw content request fails' do
      subject { described_class.new(uri: 'https://github.com/repo/blob/main/CHANGELOG.md', version: '1.0.0') }

      before do
        allow(subject).to receive(:raw_content_url).and_return(raw_content_url)
        allow(URI).to receive(:parse).with(raw_content_url).and_raise(OpenURI::HTTPError.new(
                                                                        'Not found', nil
                                                                      ))
      end

      it 'returns base URL' do
        expect(subject.changelog).to eq 'https://github.com/repo/blob/main/CHANGELOG.md'
      end
    end
  end
end
