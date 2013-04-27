$:.unshift(File.dirname(__FILE__))
require 'parsers/yahoo'
require 'requesters/yahoo'

module Barometer
  module WeatherService
    class Yahoo
      def self.accepted_formats
        [:zipcode, :weather_id, :woe_id]
      end

      def self.call(query, config={})
        WeatherService::Yahoo.new(query, config).measure!
      end

      def initialize(query, config={})
        @query = query
        @metric = config.fetch(:metric, true)
        @response = Response.new(metric)
      end

      def measure!
        convert_query!

        @requester = Barometer::Requester::Yahoo.new(metric)
        fetch_and_parse_weather

        response
      end

      private

      attr_reader :response, :metric

      def convert_query!
        @converted_query = @query.convert!(*self.class.accepted_formats)
        response.query = @converted_query.q
        response.format = @converted_query.format
      end

      def fetch_and_parse_weather
        payload = @requester.get_weather(@converted_query)
        parser = Barometer::Parser::Yahoo.new(response, @query)
        parser.parse(payload)
      end
    end
  end
end

Barometer::WeatherService.register(:yahoo, Barometer::WeatherService::Yahoo)
