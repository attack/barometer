require 'httparty'

module Barometer
  module Requester
    class WeatherBug
      include HTTParty

      def self.get_current(query, api_code, metric=true)
        puts "fetch weatherbug current: #{query.q}" if Barometer::debug?

        q = ( query.format.to_sym == :short_zipcode ?
          { :zipCode => query.q } :
          { :lat => query.q.split(',')[0], :long => query.q.split(',')[1] })

        response = self.get(
          "http://#{api_code}.api.wxbug.net/getLiveWeatherRSS.aspx",
          :query => { :ACode => api_code,
            :OutputType => "1", :UnitType => (metric ? '1' : '0')
          }.merge(q),
          :format => :plain,
          :timeout => Barometer.timeout
        )

        # WeatherBug uses non-standard XML.  Some nodes have attributes along with text values,
        # and XML parsers will ignore the attributes.
        # For a couple cases the the attribute values are needed, so grab them before XML->Hash
        # conversion and add them as separate nodes.
        #
        icon_match = response.match(/cond(\d*)\.gif/)
        icon = icon_match[1] if icon_match

        zip_match = response.match(/zipcode=\"(\d*)\"/)
        zipcode = zip_match[1] if zip_match

        output = Barometer::XmlReader.parse(response, "weather", "ob")

        output["barometer:icon"] = icon
        output["barometer:station_zipcode"] = zipcode

        Barometer::Payload.new(output)
      end

      def self.get_forecast(query, api_code, metric=true)
        puts "fetch weatherbug forecast: #{query.q}" if Barometer::debug?

        q = ( query.format.to_sym == :short_zipcode ?
          { :zipCode => query.q } :
          { :lat => query.q.split(',')[0], :long => query.q.split(',')[1] })

        response = self.get(
          "http://#{api_code}.api.wxbug.net/getForecastRSS.aspx",
          :query => { :ACode => api_code,
            :OutputType => "1", :UnitType => (metric ? '1' : '0')
          }.merge(q),
          :format => :plain,
          :timeout => Barometer.timeout
        )

        output = Barometer::XmlReader.parse(response, "weather", "forecasts")
        Barometer::Payload.new(output)
      end

    end
  end
end
