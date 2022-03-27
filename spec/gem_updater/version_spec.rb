# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GemUpdater::VERSION do
  subject(:version) { GemUpdater::VERSION }

  it { is_expected.to match(/\A\d+\.\d+\.\d+(\.\w+)?\z/) }
end
