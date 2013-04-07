$:.unshift(File.dirname(__FILE__))
require 'parsers/wunderground'
require 'requesters/wunderground'

module Barometer
  class WeatherService::Wunderground
    def self.accepted_formats
      [:zipcode, :postalcode, :icao, :coordinates, :geocode]
    end

    def self.call(query, config={})
      WeatherService::Wunderground.new(query, config).measure!
    end

    def initialize(query, config={})
      @query = query
      @metric = config.fetch(:metric, true)

      @measurement = Measurement.new(metric)
    end

    def measure!
      convert_query!

      @requester = Barometer::Requester::Wunderground.new(metric)
      fetch_and_parse_current
      fetch_and_parse_forecast

      measurement
    end

    private

    attr_reader :measurement, :metric

    def convert_query!
      @converted_query = @query.convert!(*self.class.accepted_formats)
      measurement.query = @converted_query.q
      measurement.format = @converted_query.format
    end

    def fetch_and_parse_current
      payload = @requester.get_current(@converted_query)
      parser = Barometer::Parser::Wunderground.new(measurement, @query)
      parser.parse_current(payload)
    end

    def fetch_and_parse_forecast
      payload = @requester.get_forecast(@converted_query)
      parser = Barometer::Parser::Wunderground.new(measurement, @query)
      parser.parse_forecast(payload)
    end
  end
end

Barometer::WeatherService.register(:wunderground, Barometer::WeatherService::Wunderground)
