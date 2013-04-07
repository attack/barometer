module Barometer
  module Converter
    class ToGeocode
      def initialize(query)
        @query = query
      end

      def call
        return unless can_convert?

        @query.geo = Barometer::WebService::Geocode.fetch(@query)
        @query.country_code = @query.geo.country_code
        @query.add_conversion(:geocode, @query.geo.to_s)
      end

      private

      def can_convert?
        !!@query.get_conversion(:short_zipcode, :zipcode, :postalcode, :coordinates, :icao)
      end
    end
  end
end
