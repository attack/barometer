require_relative 'noaa/forecast_api'
require_relative 'noaa/forecast_response'
require_relative 'noaa/current_api'
require_relative 'noaa/current_response'

module Barometer
  module WeatherService
    class Noaa
      def self.call(query, config={})
        Noaa.new(query).measure!
      end

      def initialize(query)
        @query = query
      end

      def measure!
        forecast_weather_api = ForecastApi.new(query)
        response = ForecastResponse.new.parse(forecast_weather_api.get)
        forecast_weather_api.query.add_conversion(:coordinates, response.location.coordinates)

        current_weather_api = CurrentApi.new(forecast_weather_api.query)
        CurrentResponse.new(response).parse(current_weather_api.get)
      end

      private

      attr_reader :query
    end
  end
end

Barometer::WeatherService.register(:noaa, Barometer::WeatherService::Noaa)
