require_relative 'apis/yahoo_placefinder'

module Barometer
  module Query
    module Service
      class YahooGeocode
        def initialize(query)
          @query = query
        end

        def call
          converted_query = query.get_conversion(:woe_id, :ipv4_address)
          return unless converted_query

          @payload = YahooPlacefinder::Api.new(converted_query).get
          parse_payload
        end

        private

        attr_reader :query, :payload

        def parse_payload
          Data::Geo.new(
            latitude: latitude,
            longitude: longitude,
            locality: locality,
            region: region,
            country: country,
            country_code: country_code,
            postal_code: postal_code,
            query: full_query
          )
        end

        def latitude
          payload.fetch('latitude')
        end

        def longitude
          payload.fetch('longitude')
        end

        def locality
          payload.fetch('city')
        end

        def region
          payload.fetch('statecode') || payload.fetch('state')
        end

        def country
          payload.fetch('country')
        end

        def country_code
          payload.fetch('countrycode')
        end

        def postal_code
          payload.fetch('uzip')
        end

        def full_query
        end
      end
    end
  end
end
