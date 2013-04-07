module Barometer
  module Converter
    class FromWoeIdToGeocode
      def self.from
        [:woe_id]
      end

      def initialize(query)
        @query = query
      end

      def call
        return unless can_convert?

        response = Barometer::WebService::Placemaker.reverse(@query)
        @query.add_conversion(:geocode, format_response(response))
      end

      private

      def can_convert?
        !!@query.get_conversion(*self.class.from)
      end

      def format_response(response)
        [response["city"], response["region"], response["country"]].select{|r|!r.empty?}.join(', ')
      end
    end
  end
end

Barometer::Converters.register(:geocode, Barometer::Converter::FromWoeIdToGeocode)
