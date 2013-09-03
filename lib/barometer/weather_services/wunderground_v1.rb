require 'barometer/weather_services/wunderground_v1/query'
require 'barometer/weather_services/wunderground_v1/current_request'
require 'barometer/weather_services/wunderground_v1/current_response'
require 'barometer/weather_services/wunderground_v1/forecast_request'
require 'barometer/weather_services/wunderground_v1/forecast_response'

module Barometer
  module WeatherService
    class WundergroundV1
      def self.call(query, config={})
        WundergroundV1.new(query).measure!
      end

      def initialize(query)
        @query = query
      end

      def measure!
        current_response = measure_current
        add_forecast(current_response)
      end

      private

      attr_reader :query

      def converted_query
        @converted_query ||= WundergroundV1::Query.new(query)
      end

      def measure_current
        current_payload = WundergroundV1::CurrentRequest.new(converted_query).get_weather
        WundergroundV1::CurrentResponse.new(converted_query, current_payload).parse
      end

      def add_forecast(response)
        forecast_payload = WundergroundV1::ForecastRequest.new(converted_query).get_weather
        WundergroundV1::ForecastResponse.new(forecast_payload, response).parse
      end
    end
  end
end

Barometer::WeatherService.register(:wunderground, :v1, Barometer::WeatherService::WundergroundV1)
