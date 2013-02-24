require 'httparty'

module Barometer
  module Requester
    class Noaa
      include HTTParty

      def self.get_current(station_id)
        puts "fetch NOAA current weather: #{query.q}" if Barometer::debug?

        response = self.get(
          "http://w1.weather.gov/xml/current_obs/#{station_id}.xml",
          :query => {},
          :format => :plain,
          :timeout => Barometer.timeout
        )

        output = Barometer::XmlReader.parse(response, "current_observation")
        Barometer::Payload.new(output)
      end

      def self.get_forecast(query, metric=true)
        puts "fetch NOAA forecast: #{query.q}" if Barometer::debug?

        q = case query.format.to_sym
            when :short_zipcode
              { :zipCodeList => query.q }
            when :zipcode
              { :zipCodeList => query.q }
            when :coordinates
              { :lat => query.q.split(',')[0], :lon => query.q.split(',')[1] }
            else
              {}
            end

        response = self.get(
          "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php",
          :query => {
            :format => "24 hourly",
            :numDays => "7"
          }.merge(q),
          :format => :plain,
          :timeout => Barometer.timeout
        )

        output = Barometer::XmlReader.parse(response, "dwml", "data")
        Barometer::Payload.new(output)
      end
    end
  end
end
