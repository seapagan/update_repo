$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'should_not/rspec'
require 'simplecov'
require 'pullreview/coverage'
require 'coveralls'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
  PullReview::Coverage::Formatter
]
SimpleCov.start

require 'pp' # work around https://github.com/defunkt/fakefs/issues/99
require 'update_repo'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
