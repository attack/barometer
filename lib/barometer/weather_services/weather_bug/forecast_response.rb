$:.unshift(File.dirname(__FILE__))
require 'weather_bug/response/forecasted_weather'
require 'weather_bug/response/location'

module Barometer
  module WeatherService
    class WeatherBug
      class ForecastResponse
        def initialize(payload, response)
          @payload = payload
          @response = response
        end

        def parse
          response.forecast = WeatherBug::Response::ForecastedWeather.new(payload, timezone).parse
          response.location = WeatherBug::Response::Location.new(payload).parse

          response
        end

        private

        attr_reader :payload, :response

        def timezone
          response.timezone
        end
      end
    end
  end
end
