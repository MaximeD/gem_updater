# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater do
  let(:updater) { GemUpdater::Updater.new }

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

      * json 2.6.3 → 2.10.2
      [changelog](https://github.com/ruby/json/blob/master/CHANGES.md#2025-03-12-2102)

      * minitest 5.20.0 → 5.25.5
      [changelog](https://github.com/minitest/minitest/blob/master/History.rdoc#5255--2025-03-12-)

      * parallel 1.23.0 → 1.26.3

      * parser 3.2.2.3 → 3.3.7.4
      [changelog](https://github.com/whitequark/parser/blob/v3.3.7.4/CHANGELOG.md)

      * racc 1.7.1 → 1.8.1
      [changelog](https://github.com/ruby/racc/releases)

      * regexp_parser 2.6.1 → 2.10.0
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md#2100---2024-12-25---janosch-müller)

      * rubocop 1.38.0 → 1.75.1
      [changelog](https://github.com/rubocop/rubocop/releases/tag/v1.75.1)

      * rubocop-ast 1.29.0 → 1.43.0
      [changelog](https://github.com/rubocop/rubocop-ast/blob/master/CHANGELOG.md#1430-2025-03-25)

      * unicode-display_width 2.4.2 → 3.1.4
      [changelog](https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md#314)

    OUTPUT
  end

  it 'outputs changelogs',
     vcr: { cassette_name: 'acceptance', record: :new_episodes } do
    updater.update!(['--gemfile=spec/acceptance/Gemfile'])
    expect { updater.output_diff }.to output(diff).to_stdout
  end
end
