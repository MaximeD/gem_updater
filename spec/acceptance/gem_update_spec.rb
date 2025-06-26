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
      * activesupport 7.0.0 → 8.0.2
      [changelog](https://github.com/rails/rails/blob/v8.0.2/activesupport/CHANGELOG.md#rails-802-march-12-2025)

      * ast 2.4.2 → 2.4.3

      * concurrent-ruby 1.2.2 → 1.3.5
      [changelog](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/CHANGELOG.md#release-v135-edge-v072-15-january-2025)

      * i18n 1.14.1 → 1.14.7
      [changelog](https://github.com/ruby-i18n/i18n/releases)

      * json 2.6.3 → 2.12.0
      [changelog](https://github.com/ruby/json/blob/master/CHANGES.md#2025-05-12-2120)

      * minitest 5.20.0 → 5.25.5
      [changelog](https://github.com/minitest/minitest/blob/master/History.rdoc#5255--2025-03-12-)

      * parallel 1.23.0 → 1.27.0

      * parser 3.2.2.3 → 3.3.8.0
      [changelog](https://github.com/whitequark/parser/blob/v3.3.8.0/CHANGELOG.md)

      * racc 1.7.1 → 1.8.1
      [changelog](https://github.com/ruby/racc/releases)

      * regexp_parser 2.6.1 → 2.10.0
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md#2100---2024-12-25---janosch-müller)

      * rubocop 1.38.0 → 1.75.6
      [changelog](https://github.com/rubocop/rubocop/releases/tag/v1.77.0)

      * rubocop-ast 1.29.0 → 1.44.1
      [changelog](https://github.com/rubocop/rubocop-ast/blob/master/CHANGELOG.md#1441-2025-04-11)

      * unicode-display_width 2.4.2 → 3.1.4
      [changelog](https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md#314)

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
