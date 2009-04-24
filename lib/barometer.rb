$:.unshift(File.dirname(__FILE__))

require 'barometer/base'
require 'barometer/query'
require 'barometer/weather'
require 'barometer/services'
require 'barometer/data'
 
module Barometer
  
  @@google_geocode_key = nil
  def self.google_geocode_key; @@google_geocode_key; end;
  def self.google_geocode_key=(key); @@google_geocode_key = key; end;
  
  @@skip_graticule = false
  def self.skip_graticule; @@skip_graticule; end;
  def self.skip_graticule=(value); @@skip_graticule = value; end;
  
  def self.new(query=nil)
    Barometer::Base.new(query)
  end
  
  def self.selection=(selection=nil)
    Barometer::Base.selection = selection
  end
  
  # shortcut to Barometer::Service.source method
  # allows Barometer.source(:wunderground)
  def self.source(source)
    Barometer::Service.source(source)
  end

  # custom errors
  class OutOfSources < StandardError; end
  
end

