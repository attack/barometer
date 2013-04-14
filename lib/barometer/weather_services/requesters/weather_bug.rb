module Barometer
  module Requester
    class WeatherBug
      def initialize(api_code, metric=true)
        @api_code = api_code
        @metric = metric
      end

      def get_current(query)
        puts "fetch weatherbug current: #{query.q}" if Barometer::debug?

        response = _get("getLiveWeatherRSS.aspx", query)

        # Some nodes have attributes along with text values, and
        # XML parsers will ignore the attributes. For a couple
        # fields the the attribute values are needed, so grab them
        # before XML->Hash conversion and add them as separate nodes.
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

      def get_forecast(query)
        puts "fetch weatherbug forecast: #{query.q}" if Barometer::debug?

        response = _get("getForecastRSS.aspx", query)
        output = Barometer::XmlReader.parse(response, "weather", "forecasts")
        Barometer::Payload.new(output)
      end

      private

      attr_reader :api_code, :metric

      def _get(path, query)
        address = Barometer::Http::Address.new(
          "http://#{api_code}.api.wxbug.net/#{path}",
          _format_request.merge(_format_query(query))
        )
        Barometer::Http::Requester.get(address)
      end

      def _format_request
        { :ACode => api_code, :OutputType => "1", :UnitType => _unit_type }
      end

      def _format_query(query)
        if query.format == :short_zipcode
          { :zipCode => query.q }
        else
          { :lat => query.latitude, :long => query.longitude }
        end
      end

      def _unit_type
        metric ? '1' : '0'
      end
    end
  end
end
