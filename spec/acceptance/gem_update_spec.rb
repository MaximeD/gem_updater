# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater do
  let(:updater) { GemUpdater::Updater.new }
  let(:acceptance_dir) { File.expand_path('spec/acceptance', "#{__dir__}/../..") }
  let(:initial_lock_content) { File.read(File.join(acceptance_dir, 'Gemfile.lock.initial')) }
  let(:updated_lock_content) { File.read(File.join(acceptance_dir, 'Gemfile.lock.updated')) }

  before do
    setup_test_files
    mock_gemfile_operations
  end

  after { `git restore spec/acceptance/Gemfile.lock` }

  let(:diff) do
    <<~OUTPUT
      * activesupport 7.0.0 → 8.1.2.1
      [changelog](https://github.com/rails/rails/blob/v8.1.2.1/activesupport/CHANGELOG.md#rails-8121-march-23-2026)

      * ast 2.4.2 → 2.4.3

      * concurrent-ruby 1.2.2 → 1.3.6
      [changelog](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/CHANGELOG.md#release-v136-13-december-2025)

      * i18n 1.14.1 → 1.14.8
      [changelog](https://github.com/ruby-i18n/i18n/releases)

      * json 2.6.3 → 2.19.2
      [changelog](https://github.com/ruby/json/blob/master/CHANGES.md#2026-03-18-2192)

      * minitest 5.20.0 → 6.0.2
      [changelog](https://github.com/minitest/minitest/blob/master/History.rdoc#602--2026-02-23)

      * parallel 1.23.0 → 1.27.0

      * parser 3.2.2.3 → 3.3.10.2
      [changelog](https://github.com/whitequark/parser/blob/v3.3.10.2/CHANGELOG.md)

      * racc 1.7.1 → 1.8.1
      [changelog](https://github.com/ruby/racc/releases)

      * regexp_parser 2.6.1 → 2.11.3
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md#2113---2025-09-15---janosch-müller)

      * rubocop 1.38.0 → 1.86.0
      [changelog](https://github.com/rubocop/rubocop/releases/tag/v1.86.0)

      * rubocop-ast 1.29.0 → 1.49.1
      [changelog](https://github.com/rubocop/rubocop-ast/blob/master/CHANGELOG.md#1491-2026-03-11)

      * unicode-display_width 2.4.2 → 3.2.0
      [changelog](https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md#320)

    OUTPUT
  end

  it 'outputs changelogs', vcr: { cassette_name: 'acceptance' } do
    Dir.chdir('spec/acceptance') do
      updater.update!(['--gemfile=Gemfile'])
    end
    expect { updater.output_diff }.to output(diff).to_stdout
  end

  private

  def setup_test_files
    FileUtils.cp('spec/acceptance/Gemfile.initial', 'spec/acceptance/Gemfile')
    File.write('spec/acceptance/Gemfile.lock', initial_lock_content)
  end

  def mock_gemfile_operations
    allow(GemUpdater::Gemfile).to receive(:new).and_wrap_original do |method|
      gemfile_instance = method.call

      allow(gemfile_instance).to receive(:update!) { Bundler.ui.warn 'Updating gems...' }
      allow(gemfile_instance).to receive(:spec_sets_diff!) {
        simulate_bundle_update(gemfile_instance)
      }

      gemfile_instance
    end
  end

  def parse_lock_file(filename)
    lock_content = File.read(filename)
    definition = Bundler::LockfileParser.new(lock_content)
    definition.specs
  end

  def simulate_bundle_update(gemfile_instance)
    old_specs = parse_lock_file('Gemfile.lock')
    File.write('Gemfile.lock', updated_lock_content)
    new_specs = parse_lock_file('Gemfile.lock')

    gemfile_instance.instance_variable_set(:@old_spec_set, old_specs)
    gemfile_instance.instance_variable_set(:@new_spec_set, new_specs)
  end
end
