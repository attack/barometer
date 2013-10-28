require_relative 'response/timezone'
require_relative 'response/current_location'
require_relative 'response/current_station'
require_relative 'response/current_weather'

module Barometer
  module WeatherService
    class Noaa
      class CurrentResponse
        def initialize(response)
          @response = response
        end

        def parse(payload)
          response.timezone = Noaa::Response::TimeZone.new(payload).parse
          response.location = Noaa::Response::CurrentLocation.new(payload, response).parse
          response.station = Noaa::Response::CurrentStation.new(payload, response).parse
          response.current = Noaa::Response::CurrentWeather.new(payload).parse

          response
        end

        private

        attr_reader :response
      end
    end
  end
end
