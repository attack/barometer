require_relative 'response/forecasted_weather'
require_relative 'response/location'

module Barometer
  module WeatherService
    class WeatherBug
      class ForecastResponse
        def initialize(response)
          @response = response
        end

        def parse(payload)
          response.forecast = WeatherBug::Response::ForecastedWeather.new(payload, timezone).parse
          response.location = WeatherBug::Response::Location.new(payload).parse

          response
        end

        private

        attr_reader :response

        def timezone
          response.timezone
        end
      end
    end
  end
end
