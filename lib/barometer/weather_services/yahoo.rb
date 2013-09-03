require 'barometer/weather_services/yahoo/query'
require 'barometer/weather_services/yahoo/request'
require 'barometer/weather_services/yahoo/response'

module Barometer
  module WeatherService
    class Yahoo
      def self.call(query, config={})
        Yahoo.new(query).measure!
      end

      def initialize(query)
        @query = query
      end

      def measure!
        converted_query = Yahoo::Query.new(query)
        payload = Yahoo::Request.new(converted_query).get_weather
        Yahoo::Response.new(converted_query, payload).parse
      end

      private

      attr_reader :query
    end
  end
end

Barometer::WeatherService.register(:yahoo, Barometer::WeatherService::Yahoo)
