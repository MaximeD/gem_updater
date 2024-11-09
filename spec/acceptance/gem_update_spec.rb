# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater do
  let(:updater) { GemUpdater::Updater.new }

  after { `git restore spec/acceptance/Gemfile.lock` }

  let(:diff) do
    <<~OUTPUT
      * activesupport 7.0.0 → 8.0.0
      [changelog](https://github.com/rails/rails/blob/v8.0.0/activesupport/CHANGELOG.md#rails-800-november-07-2024)

      * concurrent-ruby 1.2.2 → 1.3.4
      [changelog](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/CHANGELOG.md#release-v134-10-august-2024)

      * i18n 1.14.1 → 1.14.6
      [changelog](https://github.com/ruby-i18n/i18n/releases)

      * json 2.6.3 → 2.8.1
      [changelog](https://github.com/ruby/json/blob/master/CHANGES.md#2024-11-06-281)

      * minitest 5.20.0 → 5.25.1
      [changelog](https://github.com/minitest/minitest/blob/master/History.rdoc#5251--2024-08-16-)

      * parallel 1.23.0 → 1.26.3

      * parser 3.2.2.3 → 3.3.6.0
      [changelog](https://github.com/whitequark/parser/blob/v3.3.6.0/CHANGELOG.md)

      * racc 1.7.1 → 1.8.1
      [changelog](https://github.com/ruby/racc/releases)

      * regexp_parser 2.6.1 → 2.9.2
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md#292---2024-05-15---janosch-müller)

      * rubocop 1.38.0 → 1.68.0
      [changelog](https://github.com/rubocop/rubocop/releases/tag/v1.68.0)

      * rubocop-ast 1.29.0 → 1.34.1
      [changelog](https://github.com/rubocop/rubocop-ast/blob/master/CHANGELOG.md#1341-2024-11-07)

      * unicode-display_width 2.4.2 → 2.6.0
      [changelog](https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md#260)

    OUTPUT
  end

  it 'outputs changelogs',
     vcr: { cassette_name: 'acceptance', record: :new_episodes } do
    updater.update!(['--gemfile=spec/acceptance/Gemfile'])
    expect { updater.output_diff }.to output(diff).to_stdout
  end
end
