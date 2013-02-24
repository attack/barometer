$:.unshift(File.dirname(__FILE__))
require 'parsers/noaa'
require 'requesters/noaa'

module Barometer
  class WeatherService::Noaa
    def self.accepted_formats
      [:zipcode, :coordinates]
    end

    def self.call(query, config={})
      WeatherService::Noaa.new(query, config).measure!
    end

    def initialize(query, config={})
      @query = query
      @converted_query = nil
      @measurement = Measurement.new
    end

    def measure!
      validate_query!

      fetch_and_parse_forecast
      station_id = _convert_query_to_station_id
      fetch_and_parse_current(station_id)

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

    def fetch_and_parse_forecast
      payload = Barometer::Requester::Noaa.get_forecast(@converted_query)
      parser = Barometer::Parser::Noaa.new(@measurement, @converted_query)
      parser.parse_forecast(payload)
    end

    def fetch_and_parse_current(station_id)
      payload = Barometer::Requester::Noaa.get_current(station_id)
      parser = Barometer::Parser::Noaa.new(@measurement, @converted_query)
      parser.parse_current(payload)
    end

    def _convert_query_to_station_id
      station_id = Barometer::WebService::NoaaStation.fetch(
        @measurement.location.latitude,
        @measurement.location.longitude
      )
    end
  end
end

Barometer::WeatherService.register(:noaa, Barometer::WeatherService::Noaa)
