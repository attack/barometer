require_relative 'response/timezone'
require_relative 'response/location'
require_relative 'response/current_weather'
require_relative 'response/forecasted_weather'

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
