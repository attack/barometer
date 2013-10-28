require_relative 'apis/yahoo_weather'

module Barometer
  module Query
    module Service
      class FromWeatherId
        def initialize(query)
          @query = query
        end

        def call
          converted_query = query.get_conversion(:weather_id)
          return unless converted_query

          @payload = YahooWeather::Api.new(converted_query).get
          parse_payload
        end

        private

        attr_reader :query, :payload

        def parse_payload
          Data::Geo.new(
            locality: locality,
            region: region,
            country: country,
            country_code: country_code,
            latitude: latitude,
            longitude: longitude
          )
        end

        def locality
          payload.fetch('location', '@city')
        end

        def region
          payload.fetch('location', '@region')
        end

        def country
          _country if _country.size > 2
        end

        def country_code
          _country if _country.size <= 2
        end

        def latitude
          payload.fetch('item', 'lat')
        end

        def longitude
          payload.fetch('item', 'long')
        end

        def _country
          @country ||= payload.fetch('location', '@country')
        end
      end
    end
  end
end
