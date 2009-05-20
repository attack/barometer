$:.unshift(File.dirname(__FILE__))

# units
#
require 'data/zone'
require 'data/sun'
require 'data/geo'
require 'data/location'
require 'data/units'
require 'data/temperature'
require 'data/distance'
require 'data/speed'
require 'data/pressure'
require 'data/local_time'
require 'data/local_datetime'

# measurements
#
require 'measurements/measurement'
require 'measurements/result'
require 'measurements/result_array'