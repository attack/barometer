$:.unshift(File.dirname(__FILE__))

require 'http/address'
require 'http/get'
require 'http/post'

require 'wrappers/xml_reader'
require 'wrappers/json_reader'

# weather services
#
require 'weather_services/service'
require 'weather_services/wunderground'
require 'weather_services/yahoo'
require 'weather_services/weather_bug'
require 'weather_services/noaa'

# web services (non weather)
#
require 'web_services/geocode'
require 'web_services/yahoo_geocode'
require 'web_services/to_weather_id'
require 'web_services/timezone'
require 'web_services/to_woe_id'
require 'web_services/noaa_station_id'
