$:.unshift(File.dirname(__FILE__))

require 'barometer/version'
require 'barometer/utils'
require 'barometer/base'
require 'barometer/query'
require 'barometer/weather'
require 'barometer/data'
require 'barometer/response'
require 'barometer/weather_service'

module Barometer
  @@config = { 1 => {:wunderground => {:version => :v1}} }
  def self.config; @@config; end;
  def self.config=(hash); @@config = hash; end;

  @@debug_mode = false
  def self.debug; @@debug_mode; end;
  def self.debug=(value); @@debug_mode = value; end;
  def self.debug!; @@debug_mode = true; end;
  def self.debug?; @@debug_mode; end;

  @@yahoo_placemaker_app_id = nil
  def self.yahoo_placemaker_app_id; @@yahoo_placemaker_app_id; end;
  def self.yahoo_placemaker_app_id=(yahoo_key); @@yahoo_placemaker_app_id = yahoo_key; end;

  @@timeout = 15
  def self.timeout; @@timeout; end;
  def self.timeout=(value); @@timeout = value; end;

  def self.new(query)
    Barometer::Base.new(query)
  end

  class OutOfSources < StandardError; end
  class TimeoutError < StandardError; end
end
