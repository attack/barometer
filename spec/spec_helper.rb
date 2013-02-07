require 'rubygems'
require 'rspec'
require 'cgi'
require 'pry'
require 'fakefs/spec_helpers'

require File.expand_path(File.dirname(__FILE__) + '/fakeweb_helper')

$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
require 'barometer'

WEATHER_PARTNER_KEY = Barometer::KeyFileParser.find(:weather, :partner)
WEATHER_LICENSE_KEY = Barometer::KeyFileParser.find(:weather, :license)
WEATHERBUG_CODE = Barometer::KeyFileParser.find(:weather_bug, :code)
YAHOO_KEY = Barometer::KeyFileParser.find(:yahoo, :app_id)

#Barometer.debug!
Barometer.yahoo_placemaker_app_id = "YAHOO"

RSpec.configure do |config|
end
