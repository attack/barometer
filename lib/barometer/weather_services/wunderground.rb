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
      @converted_query = nil
      @measurement = Measurement.new
    end

    def measure!
      validate_query!

      fetch_and_parse_current
      fetch_and_parse_forecast

      @measurement
    end

    private

    def validate_query!
      @converted_query = @query.convert!(self.class.accepted_formats)

      if @converted_query && self.class.accepted_formats.include?(@converted_query.format)
        @measurement.query = @converted_query.q
        @measurement.format = @converted_query.format
      else
        raise Barometer::Query::ConversionNotPossible
      end
    end

    def fetch_and_parse_current
      payload = Barometer::Requester::Wunderground.get_current(@converted_query)
      parser = Barometer::Parser::Wunderground.new(@measurement, @converted_query)
      parser.parse_current(payload)
    end

    def fetch_and_parse_forecast
      payload = Barometer::Requester::Wunderground.get_forecast(@converted_query)
      parser = Barometer::Parser::Wunderground.new(@measurement, @converted_query)
      parser.parse_forecast(payload)
    end
  end
end

Barometer::WeatherService.register(:wunderground, Barometer::WeatherService::Wunderground)
