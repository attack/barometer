$:.unshift(File.dirname(__FILE__))
require 'parsers/noaa_current'
require 'parsers/noaa_forecast'
require 'requesters/noaa'

module Barometer
  module WeatherService
    class Noaa
      def self.accepted_formats
        [:zipcode, :coordinates]
      end

      def self.call(query, config={})
        WeatherService::Noaa.new(query, config).measure!
      end

      def initialize(query, config={})
        @query = query
        @converted_query = nil
        @metric = config.fetch(:metric, true)

        @measurement = Measurement.new(metric)
      end

      def measure!
        convert_query!

        @requester = Barometer::Requester::Noaa.new(metric)
        fetch_and_parse_forecast
        fetch_and_parse_current

        measurement
      end

      private

      attr_reader :measurement, :api_code, :metric

      def convert_query!
        @converted_query = @query.convert!(*self.class.accepted_formats)
        measurement.query = @converted_query.q
        measurement.format = @converted_query.format
      end

      def fetch_and_parse_forecast
        payload = @requester.get_forecast(@converted_query)
        forecast_parser = Barometer::Parser::NoaaForecast.new(measurement, @query)
        forecast_parser.parse(payload)
      end

      def fetch_and_parse_current
        # this conversion is delayed until after forecast has been parsed
        converted_query = @query.convert!(:noaa_station_id)

        payload = @requester.get_current(converted_query)
        current_parser = Barometer::Parser::NoaaCurrent.new(measurement, @query)
        current_parser.parse(payload)
      end
    end
  end
end

Barometer::WeatherService.register(:noaa, Barometer::WeatherService::Noaa)
