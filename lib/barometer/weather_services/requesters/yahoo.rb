module Barometer
  module Requester
    class Yahoo
      def initialize(query)
        @query = query
      end

      def get_weather
        response = _get
        output = Barometer::Utils::XmlReader.parse(response, 'rss', 'channel')
        Barometer::Utils::Payload.new(output)
      end

      private

      attr_reader :query

      def _get
        Barometer::Utils::Get.call(
          'http://weather.yahooapis.com/forecastrss',
          _format_request
        )
      end

      def _format_request
        { :u => _unit_type }.merge(_format_query)
      end

      def _format_query
        if query.format == :woe_id
          { :w => query.q }
        else
          { :p => query.q }
        end
      end

      def _unit_type
        query.metric? ? 'c' : 'f'
      end
    end
  end
end
