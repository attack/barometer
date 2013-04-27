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
      measurement_started_at = Time.now.utc

      begin
        measurement = source(key).call(query)
        if measurement.complete?
          measurement.status_code = 200
        else
          measurement.status_code = 204
        end

      rescue Barometer::WeatherService::KeyRequired
        measurement = Barometer::Measurement.new
        measurement.status_code = 401

      rescue Barometer::Query::ConversionNotPossible
        measurement = Barometer::Measurement.new
        measurement.status_code = 406

      rescue Barometer::Query::UnsupportedRegion
        measurement = Barometer::Measurement.new
        measurement.status_code = 406

      rescue Timeout::Error
        measurement = Barometer::Measurement.new
        measurement.status_code = 408
      end

      measurement.measurement_started_at = measurement_started_at
      measurement.measurement_ended_at = Time.now.utc
      measurement.source = key
      measurement
    end

    class KeyRequired < StandardError; end
    class NotFound < StandardError; end
  end
end

require 'weather_services/wunderground'
require 'weather_services/yahoo'
require 'weather_services/weather_bug'
require 'weather_services/noaa'
