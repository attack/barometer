module Barometer
  module Query
    module Converter
      class FromWoeOrWeatherIdToGeocode
        #
        # yes, Yahoo! Weather knows Weather.com IDs
        #
        def self.from
          [:woe_id, :weather_id]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          response = Barometer::WebService::YahooGeocode.call(@query)
          @query.add_conversion(:coordinates, Barometer::WebService::YahooGeocode.parse_coordinates(response))
          @query.add_conversion(:geocode, Barometer::WebService::YahooGeocode.parse_geocode(response))
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:geocode, Barometer::Query::Converter::FromWoeOrWeatherIdToGeocode)
