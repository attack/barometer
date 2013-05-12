module Barometer
  module Query
    module Converter
      class ToGeocode
        def self.from
          [:short_zipcode, :zipcode, :postalcode, :coordinates, :icao, :unknown]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          @query.geo = Service::GoogleGeocode.call(@query)
          @query.country_code = @query.geo.country_code
          @query.add_conversion(:geocode, @query.geo.to_s)
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:geocode, Barometer::Query::Converter::ToGeocode)
