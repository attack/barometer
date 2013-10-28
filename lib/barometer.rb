require_relative 'barometer/version'
require_relative 'barometer/utils'
require_relative 'barometer/base'
require_relative 'barometer/query'
require_relative 'barometer/weather'
require_relative 'barometer/data'
require_relative 'barometer/response'
require_relative 'barometer/weather_service'

module Barometer
  @@config = { 1 => {wunderground: {version: :v1}} }
  def self.config; @@config; end;
  def self.config=(hash); @@config = hash; end;

  @@timeout = 15
  def self.timeout; @@timeout; end;
  def self.timeout=(value); @@timeout = value; end;

  def self.new(*args)
    Barometer::Base.new(*args)
  end

  class OutOfSources < StandardError; end
  class TimeoutError < StandardError; end
end
