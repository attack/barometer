require 'httparty'

module Barometer
  module Requester
    class Yahoo
      include HTTParty

      def self.get_weather(query, metric=true)
        puts "fetch yahoo weather: #{query.q}" if Barometer::debug?

        options = {
          :p => query.format == :woe_id ? nil : query.q,
          :w => query.format == :woe_id ? query.q : nil,
          :u => (metric ? 'c' : 'f')
        }.delete_if {|k,v| v.nil? }

        response = self.get(
          "http://weather.yahooapis.com/forecastrss",
          :query => options,
          :format => :plain,
          :timeout => Barometer.timeout
        )

        output = Barometer::XmlReader.parse(response, "rss", "channel")
        Barometer::Payload.new(output)
      end
    end
  end
end
