require 'barometer/weather_services/wunderground_v1/response/full_timezone'
require 'barometer/weather_services/wunderground_v1/response/forecasted_weather'
require 'barometer/weather_services/wunderground_v1/response/sun'

module Barometer
  module WeatherService
    class WundergroundV1
      class ForecastResponse
        def initialize(response)
          @response = response
        end

        def parse(payload)
          response.timezone = WundergroundV1::Response::FullTimeZone.new(payload).parse
          if response.current
            response.current.sun = WundergroundV1::Response::Sun.new(payload, timezone, response).parse
          end
          response.forecast = WundergroundV1::Response::ForecastedWeather.new(payload, timezone, response).parse

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
