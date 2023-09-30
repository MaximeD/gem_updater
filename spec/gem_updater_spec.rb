# frozen_string_literal: true

require 'spec_helper'

describe GemUpdater::Updater do
  let(:gem_source) { instance_double(Bundler::Source::Rubygems) }
  let(:ruby_gems_fetcher) { instance_double(GemUpdater::RubyGemsFetcher) }
  let(:changelog_parser) { instance_double(GemUpdater::ChangelogParser) }

  let(:gemfile) do
    instance_double(
      GemUpdater::Gemfile,
      changes: { fake_gem: { versions: { old: '0.1', new: '0.2' }, source: gem_source } }
    )
  end

  let(:diff) do
    {
      fake_gem1: {
        changelog: 'fake_gem_1_url',
        versions: { old: '1.0', new: '1.1' }
      },
      fake_gem2: {
        changelog: 'fake_gem_2_url',
        versions: { old: '0.4', new: '0.4.2' }
      }
    }
  end

  before do
    allow(GemUpdater::Gemfile).to receive(:new) { gemfile }
    allow(gem_source).to receive(:name) { 'rubygems repository https://rubygems.org/' }
    allow(GemUpdater::RubyGemsFetcher).to receive(:new) { ruby_gems_fetcher }
    allow(GemUpdater::ChangelogParser).to receive(:new) { changelog_parser }
    allow(ruby_gems_fetcher).to receive(:changelog_uri) { 'https://github.com/example/fake/changelog.md' }
    allow(changelog_parser).to receive(:changelog) { 'https://github.com/example/fake/changelog.md#1.1' }
  end

  describe '#update' do
    before do
      allow(gemfile).to receive(:update!)
      allow(gemfile).to receive(:compute_changes)
      subject.update!([])
    end

    it 'updates gemfile' do
      expect(gemfile).to have_received(:update!)
    end

    it 'computes changes' do
      expect(gemfile).to have_received(:compute_changes)
    end

    it 'fills changelogs' do
      expect(
        gemfile.changes[:fake_gem][:changelog]
      ).to eq 'https://github.com/example/fake/changelog.md#1.1'
    end
  end

  describe '#output_diff' do
    before do
      allow(gemfile).to receive(:changes) { diff }

      allow(Bundler.ui).to receive(:info)
      subject.output_diff
    end

    it 'outputs changes' do
      expect(Bundler.ui).to have_received(:info).with(<<~CHANGELOG)
        * fake_gem1 1.0 → 1.1
        [changelog](fake_gem_1_url)

        * fake_gem2 0.4 → 0.4.2
        [changelog](fake_gem_2_url)

      CHANGELOG
    end
  end

  describe '#format_diff' do
    before { allow(gemfile).to receive(:changes) { diff } }

    it 'contains changes' do
      [
        "* fake_gem1 1.0 → 1.1\n[changelog](fake_gem_1_url)\n\n",
        "* fake_gem2 0.4 → 0.4.2\n[changelog](fake_gem_2_url)\n\n"
      ].each do |message|
        expect(subject.format_diff).to include message
      end
    end
  end
end
