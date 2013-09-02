$:.unshift(File.dirname(__FILE__))
require 'noaa/forecast_query'
require 'noaa/forecast_request'
require 'noaa/forecast_response'
require 'noaa/current_query'
require 'noaa/current_request'
require 'noaa/current_response'

module Barometer
  module WeatherService
    class Noaa
      def self.call(query, config={})
        Noaa.new(query).measure!
      end

      def initialize(query)
        @query = query
      end

      def measure!
        forecast_response = measure_forecast
        update_query(forecast_response)
        add_current(forecast_response)
      end

      private

      attr_reader :query

      def measure_forecast
        forecast_query = Noaa::ForecastQuery.new(query)
        forecast_payload = Noaa::ForecastRequest.new(forecast_query).get_weather
        Noaa::ForecastResponse.new(forecast_query, forecast_payload).parse
      end

      def add_current(response)
        current_query = Noaa::CurrentQuery.new(query)
        response.add_query(current_query.converted_query)
        current_payload = Noaa::CurrentRequest.new(current_query).get_weather
        Noaa::CurrentResponse.new(current_payload, response).parse
      end

      def update_query(response)
        query.add_conversion(:coordinates, response.location.coordinates)
      end
    end
  end
end

Barometer::WeatherService.register(:noaa, Barometer::WeatherService::Noaa)
