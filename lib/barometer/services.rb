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
