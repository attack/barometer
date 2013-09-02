$:.unshift(File.dirname(__FILE__))
require 'weather_bug/query'
require 'weather_bug/current_request'
require 'weather_bug/current_response'
require 'weather_bug/forecast_request'
require 'weather_bug/forecast_response'

module Barometer
  module WeatherService
    class WeatherBug
      def self.call(query, config={})
        WeatherBug.new(query, config).measure!
      end

      def initialize(query, config={})
        @query = query
        @api_code = config[:keys][:code] if config[:keys]
      end

      def measure!
        validate_key!
        current_response = measure_current
        add_forecast(current_response)
      end

      private

      attr_reader :query, :api_code

      def validate_key!
        unless api_code && !api_code.empty?
          raise Barometer::WeatherService::KeyRequired
        end
      end

      def converted_query
        @converted_query ||= WeatherBug::Query.new(query)
      end

      def measure_current
        current_payload = WeatherBug::CurrentRequest.new(converted_query, api_code).get_weather
        WeatherBug::CurrentResponse.new(converted_query, current_payload).parse
      end

      def add_forecast(response)
        forecast_payload = WeatherBug::ForecastRequest.new(converted_query, api_code).get_weather
        WeatherBug::ForecastResponse.new(forecast_payload, response).parse
      end
    end
  end
end

Barometer::WeatherService.register(:weather_bug, Barometer::WeatherService::WeatherBug)
