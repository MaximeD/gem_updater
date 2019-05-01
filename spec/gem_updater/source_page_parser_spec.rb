# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::SourcePageParser do
  describe '#changelog' do
    context 'when gem is hosted on github' do
      subject do
        GemUpdater::SourcePageParser.new(
          url: 'https://github.com/fake_user/fake_gem', version: '0.2'
        )
      end

      context 'when there is no changelog' do
        before { allow(URI).to receive(:open) { github_gem_without_changelog } }

        it 'is nil' do
          expect(subject.changelog).to be_nil
        end
      end

      context 'when changelog is in raw text' do
        before { allow(URI).to receive(:open) { github_gem_with_raw_changelog } }

        it 'returns url of changelog' do
          expect(subject.changelog).to eq 'https://github.com/fake_user/fake_gem/blob/master/changelog.txt'
        end
      end

      context 'when changelog may contain anchor' do
        before do
          allow(URI).to receive(:open).with(
            URI('https://github.com/fake_user/fake_gem')
          ) { github_gem_with_changelog_with_anchor }

          allow(URI).to receive(:open).with(
            'https://github.com/fake_user/fake_gem/blob/master/changelog.md'
          ) { github_changelog }
        end

        it 'returns url of changelog with anchor to version' do
          expect(subject.changelog).to eq 'https://github.com/fake_user/fake_gem/blob/master/changelog.md#02'
        end
      end
    end

    describe 'handling errors' do
      context 'when url is not reachable' do
        subject do
          GemUpdater::SourcePageParser.new(
            url: 'https://token:x-oauth-basic@github.com/fake_user/fake_gem',
            version: '0.2'
          ).changelog
        end

        it { is_expected.to be false }
      end
    end
  end

  describe '#initialize' do
    subject do
      GemUpdater::SourcePageParser
        .new(url: url, version: 1)
        .instance_variable_get(:@uri)
    end

    context 'when url is standard' do
      let(:url) { 'http://example.com' }

      it 'returns it' do
        expect(subject).to eq URI('http://example.com')
      end
    end

    context 'when url is on github' do
      context 'when url is https' do
        let(:url) { 'https://github.com/fake_user/fake_gem' }

        it 'returns it' do
          expect(subject).to eq URI('https://github.com/fake_user/fake_gem')
        end
      end

      context 'when url is http' do
        let(:url) { 'http://github.com/fake_user/fake_gem' }

        it 'returns https version of it' do
          expect(subject).to eq URI('https://github.com/fake_user/fake_gem')
        end

        context 'when url host is a subdomain' do
          let(:url) { 'http://wiki.github.com/fake_user/fake_gem' }

          it 'returns https version of base domain' do
            expect(subject).to eq URI('https://github.com/fake_user/fake_gem')
          end
        end
      end
    end

    context 'when url is on bitbucket' do
      context 'when url is https' do
        let(:url) { 'https://bitbucket.org/fake_user/fake_gem' }

        it 'returns it' do
          expect(subject).to eq URI('https://bitbucket.org/fake_user/fake_gem')
        end
      end

      context 'when url is http' do
        let(:url) { 'http://bitbucket.org/fake_user/fake_gem' }

        it 'returns https version of it' do
          expect(subject).to eq URI('https://bitbucket.org/fake_user/fake_gem')
        end
      end
    end
  end
end
