module Barometer
  module Requester
    class WundergroundV1
      def initialize(query)
        @query = query
      end

      def get_current
        response = _get('WXCurrentObXML/index.xml')
        _parse_for_payload(response, 'current_observation')
      end

      def get_forecast
        response = _get('ForecastXML/index.xml')
        _parse_for_payload(response, 'forecast')
      end

      private

      attr_reader :query

      def _get(path)
        Utils::Get.call(
          "http://api.wunderground.com/auto/wui/geo/#{path}",
          {:query => query.q.dup}
        )
      end

      def _parse_for_payload(response, *keys_to_unwrap)
        output = Utils::XmlReader.parse(response, *keys_to_unwrap)
        Utils::Payload.new(output)
      end
    end
  end
end
