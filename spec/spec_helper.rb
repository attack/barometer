require 'coveralls'
Coveralls.wear!

require 'rspec'
require 'cgi'
require 'pry'
require 'vcr'
require 'webmock/rspec'
require 'barometer/support'

require_relative '../lib/barometer'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.default_cassette_options = { record: :none, serialize_with: :json }
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!

  config.include Barometer::Support::Matchers
  config.include Barometer::Support::Factory
end
