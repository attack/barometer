require_relative 'wunderground_v1/current_api'
require_relative 'wunderground_v1/current_response'
require_relative 'wunderground_v1/forecast_api'
require_relative 'wunderground_v1/forecast_response'

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
        current_weather_api = CurrentApi.new(query)
        response = CurrentResponse.new.parse(current_weather_api.get)

        forecast_weather_api = ForecastApi.new(current_weather_api.query)
        ForecastResponse.new(response).parse(forecast_weather_api.get)
      end

      private

      attr_reader :query
    end
  end
end

Barometer::WeatherService.register(:wunderground, :v1, Barometer::WeatherService::WundergroundV1)
