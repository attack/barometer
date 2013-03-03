$:.unshift(File.dirname(__FILE__))

require 'http/address'

require 'wrappers/xml_reader'

# weather services
#
require 'weather_services/service'
require 'weather_services/wunderground'
require 'weather_services/yahoo'
require 'weather_services/weather_bug'
require 'weather_services/noaa'

# web services (non weather)
#
require 'web_services/web_service'
require 'web_services/geocode'
require 'web_services/weather_id'
require 'web_services/timezone'
require 'web_services/placemaker'
require 'web_services/noaa_station_id'
