module Barometer
  module Query
    module Converter
      class FromGeocodeToCoordinates
        def self.from
          [:geocode]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?
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

Barometer::Query::Converter.register(:coordinates, Barometer::Query::Converter::FromGeocodeToCoordinates)
