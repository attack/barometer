$:.unshift(File.dirname(__FILE__))
require 'parsers/wunderground_current'
require 'parsers/wunderground_forecast'
require 'requesters/wunderground'

module Barometer
  module WeatherService
    class Wunderground
      def self.accepted_formats
        [:zipcode, :postalcode, :icao, :coordinates, :geocode]
      end

      def self.call(query, config={})
        WeatherService::Wunderground.new(query, config).measure!
      end

      def initialize(query, config={})
        @query = query
        @metric = config.fetch(:metric, true)

        @response = Response.new(metric)
      end

      def measure!
        convert_query!

        @requester = Barometer::Requester::Wunderground.new(metric)
        fetch_and_parse_current
        fetch_and_parse_forecast

        response
      end

      private

      attr_reader :response, :metric

      def convert_query!
        @converted_query = @query.convert!(*self.class.accepted_formats)
        response.query = @converted_query.q
        response.format = @converted_query.format
      end

      def fetch_and_parse_current
        payload = @requester.get_current(@converted_query)
        current_parser = Barometer::Parser::WundergroundCurrent.new(response, @query)
        current_parser.parse(payload)
      end

      def fetch_and_parse_forecast
        payload = @requester.get_forecast(@converted_query)
        forecast_parser = Barometer::Parser::WundergroundForecast.new(response, @query)
        forecast_parser.parse(payload)
      end
    end
  end
end

Barometer::WeatherService.register(:wunderground, :v1, Barometer::WeatherService::Wunderground)
