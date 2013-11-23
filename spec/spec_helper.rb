require 'coveralls'
Coveralls.wear!

require 'rspec'
require 'cgi'
require 'pry'
require 'vcr'
require 'webmock/rspec'
require 'barometer/support'

require_relative '../lib/barometer'

WEATHERBUG_CODE = Barometer::Support::KeyFileParser.find(:weather_bug, :code) || 'weatherbug'
FORECAST_IO_APIKEY = Barometer::Support::KeyFileParser.find(:forecast_io, :apikey) || 'forecastio'
downcased_weatherbug_code = WEATHERBUG_CODE.to_s
downcased_weatherbug_code[0] = WEATHERBUG_CODE.to_s[0..0].downcase

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.default_cassette_options = { record: :none, serialize_with: :json }

  config.filter_sensitive_data('WEATHERBUG_CODE') { WEATHERBUG_CODE.to_s }
  # weather bug uses api as host name.  this is downcased when the request it made
  config.filter_sensitive_data('WEATHERBUG_CODE') { downcased_weatherbug_code }
  config.filter_sensitive_data('FORECAST_IO_APIKEY') { FORECAST_IO_APIKEY.to_s }

  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include Barometer::Support::Matchers
  config.include Barometer::Support::Factory
end
