module Barometer
  module Requester
    class WeatherBug
      def initialize(api_code, query)
        @api_code = api_code
        @query = query
      end

      def get_current
        response = _get('getLiveWeatherRSS.aspx')

        # Some nodes have attributes along with text values, and
        # XML parsers will ignore the attributes. For a couple
        # fields the the attribute values are needed, so grab them
        # before XML->Hash conversion and add them as separate nodes.
        #
        icon_match = response.match(/cond(\d*)\.gif/)
        icon = icon_match[1] if icon_match
        zip_match = response.match(/zipcode=\"(\d*)\"/)
        zipcode = zip_match[1] if zip_match

        output = Barometer::Utils::XmlReader.parse(response, 'weather', 'ob')
        output['barometer:icon'] = icon
        output['barometer:station_zipcode'] = zipcode

        Barometer::Utils::Payload.new(output)
      end

      def get_forecast
        response = _get('getForecastRSS.aspx')
        output = Barometer::Utils::XmlReader.parse(response, 'weather', 'forecasts')
        Barometer::Utils::Payload.new(output)
      end

      private

      attr_reader :api_code, :query

      def _get(path)
        Barometer::Utils::Get.call(
          "http://#{api_code}.api.wxbug.net/#{path}",
          _format_request.merge(_format_query)
        )
      end

      def _format_request
        { :ACode => api_code, :OutputType => '1', :UnitType => _unit_type }
      end

      def _format_query
        if query.format == :short_zipcode
          { :zipCode => query.q }
        else
          { :lat => query.latitude, :long => query.longitude }
        end
      end

      def _unit_type
        query.metric? ? '1' : '0'
      end
    end
  end
end
