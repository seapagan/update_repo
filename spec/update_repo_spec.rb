require 'spec_helper'

RSpec.describe UpdateRepo do
  it 'has a version number' do
    expect(UpdateRepo::VERSION).not_to be nil
  end
end
