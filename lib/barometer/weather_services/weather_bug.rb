require_relative 'weather_bug/current_api'
require_relative 'weather_bug/current_response'
require_relative 'weather_bug/forecast_api'
require_relative 'weather_bug/forecast_response'

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

        current_weather_api = CurrentApi.new(query, api_code)
        response = CurrentResponse.new.parse(current_weather_api.get)

        forecast_weather_api = ForecastApi.new(current_weather_api.query, api_code)
        ForecastResponse.new(response).parse(forecast_weather_api.get)
      end

      private

      attr_reader :query, :api_code

      def validate_key!
        unless api_code && !api_code.empty?
          raise KeyRequired
        end
      end
    end
  end
end

Barometer::WeatherService.register(:weather_bug, Barometer::WeatherService::WeatherBug)
