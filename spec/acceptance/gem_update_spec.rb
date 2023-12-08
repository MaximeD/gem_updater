# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater do
  let(:updater) { GemUpdater::Updater.new }

  after { `git restore spec/acceptance/Gemfile.lock` }

  it 'outputs changelogs',
     vcr: { cassette_name: 'acceptance', record: :new_episodes } do
    updater.update!(['--gemfile=spec/acceptance/Gemfile'])
    expect { updater.output_diff }.to output(<<~OUTPUT).to_stdout
      * activesupport 7.0.0 → 7.1.2
      [changelog](https://github.com/rails/rails/blob/v7.1.2/activesupport/CHANGELOG.md#rails-712-november-10-2023)

      * json 2.6.3 → 2.7.1
      [changelog](https://github.com/flori/json/blob/master/CHANGES.md#2023-12-05-271)

      * parser 3.2.2.3 → 3.2.2.4
      [changelog](https://github.com/whitequark/parser/blob/v3.2.2.4/CHANGELOG.md)

      * racc 1.7.1 → 1.7.3

      * regexp_parser 2.6.1 → 2.8.3
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md#283---2023-12-04---janosch-müller)

      * rubocop 1.38.0 → 1.58.0
      [changelog](https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md#1580-2023-12-01)

      * rubocop-ast 1.29.0 → 1.30.0
      [changelog](https://github.com/rubocop/rubocop-ast/blob/master/CHANGELOG.md#1300-2023-10-26)

      * unicode-display_width 2.4.2 → 2.5.0
      [changelog](https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md#250)

    OUTPUT
  end
end
