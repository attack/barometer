require 'coveralls'
Coveralls.wear!

require 'rspec'
require 'cgi'
require 'pry'
require 'vcr'
require 'fakefs/spec_helpers'
require 'webmock/rspec'

$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
require 'barometer'

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

WEATHERBUG_CODE = Barometer::Utils::KeyFileParser.find(:weather_bug, :code) || 'weatherbug'
YAHOO_KEY = Barometer::Utils::KeyFileParser.find(:yahoo, :app_id) || 'yahoo'
downcased_weatherbug_code = WEATHERBUG_CODE.to_s
downcased_weatherbug_code[0] = WEATHERBUG_CODE.to_s[0..0].downcase

# Barometer.debug!
Barometer.yahoo_placemaker_app_id = 'placemaker'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.default_cassette_options = { :record => :none, :serialize_with => :json }

  config.filter_sensitive_data('WEATHERBUG_CODE') { WEATHERBUG_CODE.to_s }
  # weather bug uses api as host name.  this is downcased when the request it made
  config.filter_sensitive_data('WEATHERBUG_CODE') { downcased_weatherbug_code }
  config.filter_sensitive_data('<YAHOO_KEY>') { YAHOO_KEY.to_s }
  config.filter_sensitive_data('<PLACEMAKER_KEY>') { Barometer.yahoo_placemaker_app_id.to_s }

  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

include Barometer::Matchers
