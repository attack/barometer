module Barometer
  module Query
    module Converter
      class FromWoeIdOrIpv4ToGeocode
        def self.from
          [:woe_id, :ipv4_address]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          @query.geo = @query.geo.merge( Service::YahooGeocode.new(@query).call )

          @query.add_conversion(:coordinates, @query.geo.coordinates)
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

Barometer::Query::Converter.register(:geocode, Barometer::Query::Converter::FromWoeIdOrIpv4ToGeocode)
