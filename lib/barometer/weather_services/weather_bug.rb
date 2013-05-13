$:.unshift(File.dirname(__FILE__))
require 'parsers/weather_bug_current'
require 'parsers/weather_bug_forecast'
require 'requesters/weather_bug'

module Barometer
  module WeatherService
    class WeatherBug
      def self.accepted_formats
        [:short_zipcode, :coordinates]
      end

      def self.call(query, config={})
        WeatherService::WeatherBug.new(query, config).measure!
      end

      def initialize(query, config={})
        @query = query
        @converted_query = nil
        @metric = config.fetch(:metric, true)

        @response = Response.new(metric)

        if config[:keys]
          @api_code = config[:keys][:code]
        end
      end

      def measure!
        validate_key!
        convert_query!

        @requester = Barometer::Requester::WeatherBug.new(api_code, metric)
        fetch_and_parse_current
        fetch_and_parse_forecast

        response
      end

      private

      attr_reader :response, :api_code, :metric

      def validate_key!
        unless api_code && !api_code.empty?
          raise Barometer::WeatherService::KeyRequired
        end
      end

      def convert_query!
        @converted_query = @query.convert!(*self.class.accepted_formats)
        response.query = @converted_query.q
        response.format = @converted_query.format
      end

      def fetch_and_parse_current
        payload = @requester.get_current(@converted_query)
        current_parser = Barometer::Parser::WeatherBugCurrent.new(response)
        current_parser.parse(payload)
      end

      def fetch_and_parse_forecast
        payload = @requester.get_forecast(@converted_query)
        forecast_parser = Barometer::Parser::WeatherBugForecast.new(response)
        forecast_parser.parse(payload)
      end
    end
  end
end

Barometer::WeatherService.register(:weather_bug, Barometer::WeatherService::WeatherBug)
