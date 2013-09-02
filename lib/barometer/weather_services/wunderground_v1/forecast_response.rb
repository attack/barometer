$:.unshift(File.dirname(__FILE__))
require 'wunderground_v1/response/full_timezone'
require 'wunderground_v1/response/forecasted_weather'
require 'wunderground_v1/response/sun'

module Barometer
  module WeatherService
    class WundergroundV1
      class ForecastResponse
        def initialize(payload, response)
          @payload = payload
          @response = response
        end

        def parse
          response.timezone = WundergroundV1::Response::FullTimeZone.new(payload).parse
          response.current.sun = WundergroundV1::Response::Sun.new(payload, timezone, response).parse
          response.forecast = WundergroundV1::Response::ForecastedWeather.new(payload, timezone, response).parse

          response
        end

        private

        attr_reader :payload, :response

        def timezone
          response.timezone
        end
      end
    end
  end
end
