$:.unshift(File.dirname(__FILE__))

require 'barometer/base'
require 'barometer/query'
require 'barometer/weather'
require 'barometer/services'
require 'barometer/data'
require 'barometer/formats'
 
module Barometer
  
  @@google_geocode_key = nil
  def self.google_geocode_key; @@google_geocode_key; end;
  def self.google_geocode_key=(key); @@google_geocode_key = key; end;
  
  # sometimes a query is used as is and never gets geocoded (ie zipcode)
  # often, it is useful have queries geocoded to know where in the
  # world that query points to.  you can force the geocoding of
  # queries (even when not required) so that you have the geocoded
  # data.  the reason this isn't the default is that it will use an
  # extra web service query when not normally required
  @@force_geocode = false
  def self.force_geocode; @@force_geocode; end;
  def self.force_geocode=(value); @@force_geocode = value; end;
  def self.force_geocode!; @@force_geocode = true; end;
  
  @@timeout = 15
  def self.timeout; @@timeout; end;
  def self.timeout=(value); @@timeout = value; end;
  
  def self.new(query=nil)
    Barometer::Base.new(query)
  end
  
  def self.config=(config=nil)
    Barometer::Base.config = config
  end
  
  # shortcut to Barometer::Service.source method
  # allows Barometer.source(:wunderground)
  def self.source(source)
    Barometer::Service.source(source)
  end

  # custom errors
  class OutOfSources < StandardError; end
  
end

