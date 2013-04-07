$:.unshift(File.dirname(__FILE__))

# query formats
#
require 'formats/format'
require 'formats/short_zipcode'
require 'formats/zipcode'
require 'formats/postalcode'
require 'formats/weather_id'
require 'formats/coordinates'
require 'formats/icao'
require 'formats/woe_id'
require 'formats/geocode'

require 'converters/from_woe_id_to_geocode'
require 'converters/to_woe_id'
require 'converters/from_weather_id_to_geocode'
require 'converters/to_geocode'
require 'converters/to_coordinates'
require 'converters/from_short_zipcode_to_zipcode'
require 'converters/from_geocode_to_weather_id'
