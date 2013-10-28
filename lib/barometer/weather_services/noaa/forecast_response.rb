require_relative 'response/location'
require_relative 'response/forecasted_weather'

module Barometer
  module WeatherService
    class Noaa
      class ForecastResponse
        def initialize
          @response = Barometer::Response.new
        end

        def parse(payload)
          response.add_query(payload.query)

          response.location = Noaa::Response::Location.new(payload).parse
          response.station = response.location
          response.forecast = Noaa::Response::ForecastedWeather.new(payload).parse

          response
        end

        private

        attr_reader :response
      end
    end
  end
end
