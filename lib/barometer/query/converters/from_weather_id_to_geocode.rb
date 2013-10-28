module Barometer
  module Query
    module Converter
      class FromWeatherIdToGeocode
        def self.from
          [:weather_id]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          @query.geo = @query.geo.merge( Service::FromWeatherId.new(@query).call )
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

Barometer::Query::Converter.register(:geocode, Barometer::Query::Converter::FromWeatherIdToGeocode)
