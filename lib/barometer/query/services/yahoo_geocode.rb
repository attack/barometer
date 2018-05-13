require_relative 'apis/yahoo'

module Barometer
  module Query
    module Service
      class YahooGeocode
        def initialize(query)
          @query = query
        end

        def call
          converted_query = query.get_conversion(:woe_id)
          return unless converted_query

          @payload = Yahoo::Api.new(converted_query).get
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
          payload.fetch('centroid', 'latitude')
        end

        def longitude
          payload.fetch('centroid', 'longitude')
        end

        def locality
          payload.fetch('locality1', 'content')
        end

        def region
          payload.fetch('admin1', 'content')
        end

        def country
          payload.fetch('country', 'content')
        end

        def country_code
          payload.fetch('country', 'code')
        end

        def postal_code
          payload.fetch('postal', 'content')
        end

        def full_query
        end
      end
    end
  end
end
