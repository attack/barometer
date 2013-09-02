$:.unshift(File.dirname(__FILE__))
require 'weather_bug/response/timezone'
require 'weather_bug/response/current_weather'
require 'weather_bug/response/station'

module Barometer
  module WeatherService
    class WeatherBug
      class CurrentResponse
        def initialize(query, payload)
          @response = Barometer::Response.new(query.converted_query)
          @payload = payload
        end

        def parse
          response.timezone = WeatherBug::Response::TimeZone.new(payload).parse
          response.current = WeatherBug::Response::CurrentWeather.new(payload, timezone).parse
          response.station = WeatherBug::Response::Station.new(payload).parse

          response
        end

        private

        attr_reader :response, :payload

        def timezone
          response.timezone
        end
      end
    end
  end
end
