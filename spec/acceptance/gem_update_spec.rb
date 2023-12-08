# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater do
  let(:updater) { GemUpdater::Updater.new }

  around(:example) do |example|
    current_working_directory = Dir.pwd

    Dir.chdir('spec/acceptance/')
    example.run
    Dir.chdir(current_working_directory)

    `git restore Gemfile.lock`
  end

  it 'outputs changelogs',
     vcr: { cassette_name: 'acceptance', record: :new_episodes } do
    updater.update!([])
    expect { updater.output_diff }.to output(<<~OUTPUT).to_stdout
      * json 2.6.3 → 2.7.1
      [changelog](https://github.com/flori/json/blob/master/CHANGES.md#2023-12-05-271)

      * mini_portile2 2.8.4 → 2.8.5

      * nokogiri 1.15.4 → 1.15.5
      [changelog](https://nokogiri.org/CHANGELOG.html)

      * parser 3.2.2.3 → 3.2.2.4
      [changelog](https://github.com/whitequark/parser/blob/v3.2.2.4/CHANGELOG.md)

      * public_suffix 5.0.3 → 5.0.4
      [changelog](https://github.com/weppos/publicsuffix-ruby/blob/master/CHANGELOG.md#504)

      * racc 1.7.1 → 1.7.3

      * rake 13.0.6 → 13.1.0
      [changelog](https://github.com/ruby/rake/blob/v13.1.0/History.rdoc)

      * regexp_parser 2.8.1 → 2.8.3
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md#283---2023-12-04---janosch-müller)

      * rubocop 1.56.4 → 1.58.0
      [changelog](https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md#1580-2023-12-01)

      * rubocop-ast 1.29.0 → 1.30.0
      [changelog](https://github.com/rubocop/rubocop-ast/blob/master/CHANGELOG.md#1300-2023-10-26)

      * unicode-display_width 2.4.2 → 2.5.0
      [changelog](https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md#250)

    OUTPUT
  end
end
