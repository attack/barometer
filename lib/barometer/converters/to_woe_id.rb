module Barometer
  module Converter
    class ToWoeId
      def initialize(query)
        @query = query
      end

      def call
        return unless can_convert?

        response = Barometer::WebService::Placemaker.fetch(@query)
        @query.add_conversion(:woe_id, format_response(response))
      end

      private

      def can_convert?
        !!@query.get_conversion(:geocode, :coordinates, :postalcode)
      end

      def format_response(response)
        Barometer::WebService::Placemaker.parse_woe_id(response)
      end
    end
  end
end
