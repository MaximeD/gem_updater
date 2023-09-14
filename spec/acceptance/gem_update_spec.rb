# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater do
  let(:updater) { GemUpdater::Updater.new }

  before { ENV['BUNDLE_GEMFILE'] = 'spec/acceptance/Gemfile' }

  after { `git restore spec/acceptance/Gemfile.lock` }

  it 'outputs changelogs',
     vcr: { cassette_name: 'acceptance', record: :new_episodes } do
    updater.update!([])
    expect { updater.output_diff }.to output(<<~OUTPUT).to_stdout
      * activesupport 7.0.0 → 7.0.8
      [changelog](https://github.com/rails/rails/blob/v7.0.8/activesupport/CHANGELOG.md#rails-708-september-09-2023)

      * regexp_parser 2.6.1 → 2.8.1
      [changelog](https://github.com/ammar/regexp_parser/blob/master/CHANGELOG.md#281---2023-06-10---janosch-müller)

      * rubocop 1.38.0 → 1.56.3
      [changelog](https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md#1563-2023-09-11)

    OUTPUT
  end
end
