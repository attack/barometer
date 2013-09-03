require 'barometer/weather_services/noaa/response/timezone'
require 'barometer/weather_services/noaa/response/current_location'
require 'barometer/weather_services/noaa/response/current_station'
require 'barometer/weather_services/noaa/response/current_weather'

module Barometer
  module WeatherService
    class Noaa
      class CurrentResponse
        def initialize(payload, response)
          @payload = payload
          @response = response
        end

        def parse
          response.timezone = Noaa::Response::TimeZone.new(payload).parse
          response.location = Noaa::Response::CurrentLocation.new(payload, response).parse
          response.station = Noaa::Response::CurrentStation.new(payload, response).parse
          response.current = Noaa::Response::CurrentWeather.new(payload).parse

          response
        end

        private

        attr_reader :response, :payload
      end
    end
  end
end
