require 'barometer/weather_services/wunderground_v1/response/current_weather'
require 'barometer/weather_services/wunderground_v1/response/station'
require 'barometer/weather_services/wunderground_v1/response/location'
require 'barometer/weather_services/wunderground_v1/response/timezone'

module Barometer
  module WeatherService
    class WundergroundV1
      class CurrentResponse
        def initialize
          @response = Barometer::Response.new
        end

        def parse(payload)
          response.add_query(payload.query)

          response.current = WundergroundV1::Response::CurrentWeather.new(payload).parse
          response.station = WundergroundV1::Response::Station.new(payload).parse
          response.location = WundergroundV1::Response::Location.new(payload).parse
          response.timezone = WundergroundV1::Response::TimeZone.new(payload).parse

          response
        end

        private

        attr_reader :response
      end
    end
  end
end
