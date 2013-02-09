require 'rubygems'
require 'rspec'
require 'cgi'
require 'pry'
require 'vcr'
require 'fakefs/spec_helpers'

$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
require 'barometer'

WEATHER_PARTNER_KEY = Barometer::KeyFileParser.find(:weather, :partner)
WEATHER_LICENSE_KEY = Barometer::KeyFileParser.find(:weather, :license)
WEATHERBUG_CODE = Barometer::KeyFileParser.find(:weather_bug, :code)
YAHOO_KEY = Barometer::KeyFileParser.find(:yahoo, :app_id)

#Barometer.debug!
Barometer.yahoo_placemaker_app_id = "YAHOO"

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.default_cassette_options = { :record => :new_episodes }
  config.filter_sensitive_data('<YAHOO_KEY>') { YAHOO_KEY.to_s }
  config.filter_sensitive_data('<WEATHERBUG_CODE>') { WEATHERBUG_CODE.to_s }
  config.filter_sensitive_data('<WEATHER_PARTNER_KEY>') { WEATHER_PARTNER_KEY.to_s }
  config.filter_sensitive_data('<WEATHER_LICENSE_KEY>') { WEATHER_LICENSE_KEY.to_s }
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
