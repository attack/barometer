require 'barometer/weather_services/forecast_io/api'
require 'barometer/weather_services/forecast_io/response'

module Barometer
  module WeatherService
    class ForecastIo
      def self.call(query, config={})
        ForecastIo.new(query, config).measure!
      end

      def initialize(query, config={})
        @query = query
        @apikey = config[:keys][:api] if config[:keys]
      end

      def measure!
        validate_key!

        api = ForecastIo::Api.new(query, apikey)
        ForecastIo::Response.new.parse(api.get)
      end

      private

      attr_reader :query, :apikey

      def validate_key!
        unless apikey && !apikey.empty?
          raise KeyRequired
        end
      end
    end
  end
end

Barometer::WeatherService.register(:forecast_io, Barometer::WeatherService::ForecastIo)
