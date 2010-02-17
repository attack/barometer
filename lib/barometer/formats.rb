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
require 'formats/geocode'
require 'formats/woe_id'