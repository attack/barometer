module Barometer
  module WeatherService
    def self.services=(services)
      @@services = services
    end

    def self.services
      @@services
    end

    def self.register(key, service=nil, &block)
      @@services ||= {}
      if block_given?
        @@services[key] = Proc.new(&block)
      elsif
        @@services[key] = service
      else
        raise ArgumentError
      end
    end

    def self.source(key)
      @@services ||= {}
      @@services[key] or raise NotFound
    end

    def self.measure(key, query, metric=true)
      response_started_at = Time.now.utc

      begin
        response = source(key).call(query)
        if response.complete?
          response.status_code = 200
        else
          response.status_code = 204
        end

      rescue Barometer::WeatherService::KeyRequired
        response = Barometer::Response.new
        response.status_code = 401

      rescue Barometer::Query::ConversionNotPossible
        response = Barometer::Response.new
        response.status_code = 406

      rescue Barometer::Query::UnsupportedRegion
        response = Barometer::Response.new
        response.status_code = 406

      rescue Timeout::Error
        response = Barometer::Response.new
        response.status_code = 408
      end

      response.response_started_at = response_started_at
      response.response_ended_at = Time.now.utc
      response.source = key
      response
    end

    class KeyRequired < StandardError; end
    class NotFound < StandardError; end
  end
end

require 'weather_services/wunderground'
require 'weather_services/yahoo'
require 'weather_services/weather_bug'
require 'weather_services/noaa'
