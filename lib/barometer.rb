require 'barometer/version'
require 'barometer/utils'
require 'barometer/base'
require 'barometer/query'
require 'barometer/weather'
require 'barometer/data'
require 'barometer/response'
require 'barometer/weather_service'

module Barometer
  @@config = { 1 => {wunderground: {version: :v1}} }
  def self.config; @@config; end;
  def self.config=(hash); @@config = hash; end;

  @@yahoo_placemaker_app_id = nil
  def self.yahoo_placemaker_app_id; @@yahoo_placemaker_app_id; end;
  def self.yahoo_placemaker_app_id=(yahoo_key); @@yahoo_placemaker_app_id = yahoo_key; end;

  @@timeout = 15
  def self.timeout; @@timeout; end;
  def self.timeout=(value); @@timeout = value; end;

  def self.new(*args)
    Barometer::Base.new(*args)
  end

  class OutOfSources < StandardError; end
  class TimeoutError < StandardError; end
end
