module Barometer
  module Query
    module Converter
      class ToCoordinates
        def self.from
          [:short_zipcode, :zipcode, :postalcode, :coordinates, :icao, :geocode]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          @query.geo = Service::Geocode.fetch(@query)
          @query.country_code = @query.geo.country_code
          @query.add_conversion(:coordinates, @query.geo.coordinates)
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:coordinates, Barometer::Query::Converter::ToCoordinates)
