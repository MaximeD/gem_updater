# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater do
  let(:updater) { GemUpdater::Updater.new }

  after { `git restore spec/acceptance/Gemfile.lock` }

  let(:diff) do
    <<~OUTPUT
      * activesupport 7.0.0 → 7.1.3.4
      [changelog](https://github.com/rails/rails/blob/v7.1.2/activesupport/CHANGELOG.md)

      * concurrent-ruby 1.2.2 → 1.3.3
      [changelog](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/CHANGELOG.md#release-v133-9-june-2024)

      * i18n 1.14.1 → 1.14.5
      [changelog](https://github.com/ruby-i18n/i18n/releases)

      * json 2.6.3 → 2.7.2
      [changelog](https://github.com/flori/json/blob/master/CHANGES.md)

      * minitest 5.20.0 → 5.23.1
      [changelog](https://github.com/minitest/minitest/blob/master/History.rdoc)

      * parallel 1.23.0 → 1.25.1

      * parser 3.2.2.3 → 3.3.2.0
      [changelog](https://github.com/whitequark/parser/blob/v3.2.2.4/CHANGELOG.md)

      * racc 1.7.1 → 1.8.0

      * regexp_parser 2.6.1 → 2.9.2
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md)

      * rexml 3.2.6 → 3.3.0

      * rubocop 1.38.0 → 1.64.1
      [changelog](https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md)

      * rubocop-ast 1.29.0 → 1.31.3
      [changelog](https://github.com/rubocop/rubocop-ast/blob/master/CHANGELOG.md)

      * unicode-display_width 2.4.2 → 2.5.0
      [changelog](https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md#250)

    OUTPUT
  end

  it 'outputs changelogs',
     vcr: { cassette_name: 'acceptance', record: :new_episodes } do
    updater.update!(['--gemfile=spec/acceptance/Gemfile'])
    expect { updater.output_diff }.to output(diff).to_stdout
  end
end
