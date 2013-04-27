module Barometer
  module Requester
    class Wunderground
      def initialize(metric=true)
        @metric = metric
      end

      def get_current(query)
        puts "fetch wunderground current: #{query.q}" if Barometer::debug?

        response = _get("WXCurrentObXML/index.xml", query)

        output = Barometer::XmlReader.parse(response, "current_observation")
        Barometer::Utils::Payload.new(output)
      end

      def get_forecast(query)
        puts "fetch wunderground forecast: #{query.q}" if Barometer::debug?

        response = _get("ForecastXML/index.xml", query)

        output = Barometer::XmlReader.parse(response, "forecast")
        Barometer::Utils::Payload.new(output)
      end

      private

      attr_reader :metric

      def _get(path, query)
        Barometer::Http::Get.call(
          "http://api.wunderground.com/auto/wui/geo/#{path}",
          {:query => query.q.dup}
        )
      end

    end
  end
end
