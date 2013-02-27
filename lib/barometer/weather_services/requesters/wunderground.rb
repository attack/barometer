require 'httparty'

module Barometer
  module Requester
    class Wunderground
      include HTTParty

      def initialize(metric=true)
        @metric = metric
      end

      def get_current(query)
        puts "fetch wunderground current: #{query.q}" if Barometer::debug?

        response = _get("WXCurrentObXML/index.xml", query)

        output = Barometer::XmlReader.parse(response, "current_observation")
        Barometer::Payload.new(output)
      end

      def get_forecast(query)
        puts "fetch wunderground forecast: #{query.q}" if Barometer::debug?

        response = _get("ForecastXML/index.xml", query)

        output = Barometer::XmlReader.parse(response, "forecast")
        Barometer::Payload.new(output)
      end

      private

      attr_reader :metric

      def _get(path, query)
        self.class.get(
          "http://api.wunderground.com/auto/wui/geo/#{path}",
          :query => {:query => query.q},
          :format => :plain,
          :timeout => Barometer.timeout
        )
      end

    end
  end
end
