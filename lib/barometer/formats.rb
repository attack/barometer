$:.unshift(File.dirname(__FILE__))

require 'query/formats'
require 'formats/format'
require 'formats/short_zipcode'
require 'formats/zipcode'
require 'formats/postalcode'
require 'formats/weather_id'
require 'formats/coordinates'
require 'formats/icao'
require 'formats/woe_id'
require 'formats/noaa_station_id'
require 'formats/geocode'

require 'query/converter'
