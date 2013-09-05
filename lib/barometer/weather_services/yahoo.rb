require 'barometer/weather_services/yahoo/api'
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
        api = Yahoo::Api.new(query)
        Yahoo::Response.new.parse(api.get)
      end

      private

      attr_reader :query
    end
  end
end

Barometer::WeatherService.register(:yahoo, Barometer::WeatherService::Yahoo)
