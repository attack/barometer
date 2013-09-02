$:.unshift(File.dirname(__FILE__))
require 'yahoo/response/time_zone'
require 'yahoo/response/location'
require 'yahoo/response/current_weather'
require 'yahoo/response/forecasted_weather'

module Barometer
  module WeatherService
    class Yahoo
      class Response
        def initialize(query, payload)
          @response = Barometer::Response.new(query.converted_query)
          @payload = payload
        end

        def parse
          response.timezone = Yahoo::Response::TimeZone.new(payload).parse
          response.location = Yahoo::Response::Location.new(payload).parse
          response.current = Yahoo::Response::CurrentWeather.new(payload, timezone).parse
          response.forecast = Yahoo::Response::ForecastedWeather.new(payload, timezone, current_sun).parse

          response
        end

        private

        attr_reader :response, :payload

        def timezone
          response.timezone
        end

        def current_sun
          response.current.sun
        end
      end
    end
  end
end
