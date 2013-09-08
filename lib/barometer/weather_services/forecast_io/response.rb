require 'barometer/weather_services/forecast_io/response/timezone'
require 'barometer/weather_services/forecast_io/response/location'
require 'barometer/weather_services/forecast_io/response/current_weather'
require 'barometer/weather_services/forecast_io/response/forecasted_weather'

module Barometer
  module WeatherService
    class ForecastIo
      class Response
        def initialize
          @response = Barometer::Response.new
        end

        def parse(payload)
          response.add_query(payload.query)

          response.timezone = ForecastIo::Response::TimeZone.new(payload).parse
          response.location = ForecastIo::Response::Location.new(payload).parse
          response.current = ForecastIo::Response::CurrentWeather.new(payload).parse
          response.forecast = ForecastIo::Response::ForecastedWeather.new(payload).parse

          response
        end

        private

        attr_reader :response
      end
    end
  end
end
