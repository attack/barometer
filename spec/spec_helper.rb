require 'coveralls'
Coveralls.wear!

require 'rspec'
require 'cgi'
require 'pry'
require 'vcr'
require 'webmock/rspec'
require 'barometer/support'

require_relative '../lib/barometer'

FORECAST_IO_APIKEY = Barometer::Support::KeyFileParser.find(:forecast_io, :apikey) || 'forecastio'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.default_cassette_options = { record: :none, serialize_with: :json }

  config.filter_sensitive_data('FORECAST_IO_APIKEY') { FORECAST_IO_APIKEY.to_s }

  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include Barometer::Support::Matchers
  config.include Barometer::Support::Factory
end
