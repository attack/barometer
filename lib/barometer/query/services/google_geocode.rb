require_relative 'apis/google_geocode'

module Barometer
  module Query
    module Service
      class GoogleGeocode
        def initialize(query)
          @query = query
        end

        def call
          converted_query = query.get_conversion(:short_zipcode, :zipcode, :postalcode, :coordinates, :icao, :unknown)
          return unless converted_query

          @payload = GoogleGeocode::Api.new(converted_query).get
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
          payload.fetch('geometry', 'location', 'lat')
        end

        def longitude
          payload.fetch('geometry', 'location', 'lng')
        end

        def locality
          find_name('sublocality', 'long_name') || find_name('locality', 'long_name')
        end

        def region
          find_name('administrative_area_level_1', 'short_name')
        end

        def country
          find_name('country', 'long_name')
        end

        def country_code
          find_name('country', 'short_name')
        end

        def postal_code
          find_name('postal_code', 'short_name')
        end

        def full_query
          return if query_is_street_address? || query_is_route?
          find_detected_types.map{|address_component| address_component.fetch('short_name')}.join(', ')
        end

        def address_components
          @address_components ||= payload.fetch('address_components').
            select{|address_component| address_component.has_key? 'types'}
        end

        def find_type(address_component_type)
          address_components.find do |address_component|
            address_component.fetch('types').include?(address_component_type)
          end
        end

        def find_name(address_component_type, name)
          if result = find_type(address_component_type)
            result.fetch(name)
          end
        end

        def detected_query_types
          @detected_query_types ||= payload.fetch('types')
        end

        def find_detected_types
          address_components.select do |address_component|
            (address_component.fetch('types') & detected_query_types).any?
          end
        end

        def query_is_street_address?
          detected_query_types.include? 'street_address'
        end

        def query_is_route?
          detected_query_types.include? 'route'
        end
      end
    end
  end
end
