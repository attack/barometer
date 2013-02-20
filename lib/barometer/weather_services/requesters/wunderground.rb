require 'httparty'

module Barometer
  module Requester
    class Wunderground
      include HTTParty

      def self.get_current(query, metric=true)
        puts "fetch wunderground current: #{query.q}" if Barometer::debug?

        response = self.get(
          "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml",
          :query => {:query => query.q},
          :format => :plain,
          :timeout => Barometer.timeout
        )

        output = Barometer::XmlReader.parse(response, "current_observation")
        Barometer::Payload.new(output)
      end

      def self.get_forecast(query, metric=true)
        puts "fetch wunderground forecast: #{query.q}" if Barometer::debug?

        response = self.get(
          "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml",
          :query => {:query => query.q},
          :format => :plain,
          :timeout => Barometer.timeout
        )

        output = Barometer::XmlReader.parse(response, "forecast")
        Barometer::Payload.new(output)
      end

    end
  end
end
