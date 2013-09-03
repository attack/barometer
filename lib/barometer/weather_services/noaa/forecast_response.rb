require 'barometer/weather_services/noaa/response/location'
require 'barometer/weather_services/noaa/response/forecasted_weather'

module Barometer
  module WeatherService
    class Noaa
      class ForecastResponse
        def initialize(query, payload)
          @response = Barometer::Response.new(query.converted_query)
          @payload = payload
        end

        def parse
          response.location = Noaa::Response::Location.new(payload).parse
          response.station = response.location
          response.forecast = Noaa::Response::ForecastedWeather.new(payload).parse

          response
        end

        private

        attr_reader :response, :payload
      end
    end
  end
end
