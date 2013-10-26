require_relative 'apis/yahoo_geocode'

module Barometer
  module Query
    module Service
      class YahooGeocode
        def self.call(query)
          converted_query = query.get_conversion(:woe_id, :weather_id)
          return unless converted_query

          api = YahooGeocode::Api.new(converted_query)
          _parse_payload(api.get)
        end

        def self._parse_payload(payload)
          Data::Geo.new.tap do |geo|
            geo.locality = payload.fetch('location', '@city')
            geo.region = payload.fetch('location', '@region')
            _parse_country(geo, payload)
            geo.latitude = payload.fetch('item', 'lat')
            geo.longitude = payload.fetch('item', 'long')
          end
        end

        private

        def self._parse_country(geo, payload)
          if (country = payload.fetch('location', '@country')).size > 2
            geo.country = country
          else
            geo.country_code = country
          end
        end
      end
    end
  end
end
