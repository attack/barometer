$:.unshift(File.dirname(__FILE__))
require 'parsers/yahoo'
require 'requesters/yahoo'

module Barometer
  class WeatherService::Yahoo
    def self.accepted_formats
      [:zipcode, :weather_id, :woe_id]
    end

    def self.call(query, config={})
      WeatherService::Yahoo.new(query, config).measure!
    end

    def initialize(query, config={})
      @query = query
      @converted_query = nil
      @metric = config.fetch(:metric, true)

      @measurement = Measurement.new(metric)
    end

    def measure!
      validate_query!

      @requester = Barometer::Requester::Yahoo.new(metric)
      fetch_and_parse_weather

      measurement
    end

    private

    attr_reader :measurement, :converted_query, :metric

    def validate_query!
      @converted_query = @query.convert!(self.class.accepted_formats)

      measurement.query = converted_query.q
      measurement.format = converted_query.format
    end

    def fetch_and_parse_weather
      payload = @requester.get_weather(converted_query)
      parser = Barometer::Parser::Yahoo.new(measurement, converted_query)
      parser.parse_weather(payload)
    end
  end
end

Barometer::WeatherService.register(:yahoo, Barometer::WeatherService::Yahoo)
