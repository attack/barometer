$:.unshift(File.dirname(__FILE__))

# weather services
#
require 'weather_services/service'
require 'weather_services/wunderground'
require 'weather_services/google'
require 'weather_services/yahoo'
require 'weather_services/weather_dot_com'

#
# web services (non weather)
#
require 'web_services/web_service'
require 'web_services/geocode'
require 'web_services/weather_id'