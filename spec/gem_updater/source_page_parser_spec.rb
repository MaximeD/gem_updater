# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::SourcePageParser do
  describe '#changelog' do
    subject(:changelog) { parser.changelog }

    let(:parser) { described_class.new(url: url, version: '2.1.1') }

    context 'when gem is hosted on github' do
      context 'when there is no changelog',
              vcr: { cassette_name: 'github/no_changelog' } do
        let(:url) { 'https://github.com/mailjet/mailjet-gem' }

        it { is_expected.to be_nil }
      end

      context 'when changelog is in raw text',
              vcr: { cassette_name: 'github/raw_changelog' } do
        let(:url) { 'https://github.com/ianwhite/pickle' }
        let(:expected_changelog) { 'https://github.com/ianwhite/pickle/blob/master/History.txt' }

        it 'returns url of changelog' do
          expect(changelog).to eq expected_changelog
        end
      end

      context 'when changelog may contain anchor',
              vcr: { cassette_name: 'github/changelog_with_anchor' } do
        let(:url) { 'https://github.com/MaximeD/gem_updater' }
        let(:expected_changelog) do
          'https://github.com/MaximeD/gem_updater/blob/master/CHANGELOG.md#v211-june-04-2017'
        end

        it 'returns url of changelog with anchor to version' do
          expect(changelog).to eq expected_changelog
        end
      end
    end

    describe 'handling errors' do
      context 'when url is not reachable',
              vcr: { cassette_name: 'github/unreachable' } do
        let(:url) { 'https://token:x-oauth-basic@github.com/fake_user/fake_gem' }

        it { is_expected.to be false }
      end
    end
  end

  describe '#initialize' do
    subject do
      described_class.new(url: url, version: 1).instance_variable_get(:@uri)
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
