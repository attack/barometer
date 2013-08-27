module Barometer
  module Requester
    class Wunderground
      def initialize(metric=true)
      end

      def get_current(query)
        response = _get('WXCurrentObXML/index.xml', query)
        _parse_for_payload(response, 'current_observation')
      end

      def get_forecast(query)
        response = _get('ForecastXML/index.xml', query)
        _parse_for_payload(response, 'forecast')
      end

      private

      def _get(path, query)
        Barometer::Utils::Get.call(
          "http://api.wunderground.com/auto/wui/geo/#{path}",
          {:query => query.q.dup}
        )
      end

      def _parse_for_payload(response, *keys_to_unwrap)
        output = Barometer::Utils::XmlReader.parse(response, *keys_to_unwrap)
        Barometer::Utils::Payload.new(output)
      end
    end
  end
end
