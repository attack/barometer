$:.unshift(File.dirname(__FILE__))
require 'parsers/wunderground_v1_current'
require 'parsers/wunderground_v1_forecast'
require 'requesters/wunderground_v1'

module Barometer
  module WeatherService
    class WundergroundV1
      def self.accepted_formats
        [:zipcode, :postalcode, :icao, :coordinates, :geocode]
      end

      def self.call(query, config={})
        WundergroundV1.new(query, config).measure!
      end

      def initialize(query, config={})
        @query = query
        @response = Response.new(query.metric?)
      end

      def measure!
        convert_query!

        @requester = Requester::WundergroundV1.new(@converted_query)
        fetch_and_parse_current
        fetch_and_parse_forecast

        response
      end

      private

      attr_reader :response

      def convert_query!
        @converted_query = @query.convert!(*self.class.accepted_formats)
        response.query = @converted_query.q
        response.format = @converted_query.format
      end

      def fetch_and_parse_current
        payload = @requester.get_current
        current_parser = Parser::WundergroundV1Current.new(response)
        current_parser.parse(payload)
      end

      def fetch_and_parse_forecast
        payload = @requester.get_forecast
        forecast_parser = Parser::WundergroundV1Forecast.new(response)
        forecast_parser.parse(payload)
      end
    end
  end
end

Barometer::WeatherService.register(:wunderground, :v1, Barometer::WeatherService::WundergroundV1)
