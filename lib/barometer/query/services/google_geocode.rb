module Barometer
  module Query
    module Service
      class GoogleGeocode
        def self.call(query)
          converted_query = query.get_conversion(:short_zipcode, :zipcode, :postalcode, :coordinates, :icao, :unknown)
          return unless converted_query

          response =  Barometer::Utils::Get.call(
            'http://maps.googleapis.com/maps/api/geocode/json',
            _format_params(converted_query)
          )

          Barometer::Utils::JsonReader.parse(response, 'results') do |result|
            _parse_result(result.first)
          end
        end

        def self._format_params(query)
          params = { :sensor => 'false' }
          params[:region] = query.geo.country_code if query.geo.country_code

          if query.format == :coordinates
            params[:latlng] = query.q.dup
          else
            params[:address] = query.q.dup
          end
          params
        end

        def self._parse_result(result)
          payload = Utils::Payload.new(result)

          Data::Geo.new.tap do |geo|
            geo.latitude = payload.fetch('geometry', 'location', 'lat')
            geo.longitude = payload.fetch('geometry', 'location', 'lng')

            detected_query_types = payload.fetch('types')
            query_parts = []

            payload.each('address_components') do |address_payload|
              skip unless address_payload.fetch('types')

              _parse_locality(geo, address_payload)
              _parse_region(geo, address_payload)
              _parse_country(geo, address_payload)
              _parse_postal_code(geo, address_payload)
              _parse_query(geo, address_payload, detected_query_types, query_parts)
            end
          end
        end

        def self._parse_locality(geo, payload)
          if payload.fetch('types').include?('sublocality')
            geo.locality = payload.fetch('long_name')
          end
          if payload.fetch('types').include?('locality')
            geo.locality ||= payload.fetch('long_name')
          end
        end

        def self._parse_region(geo, payload)
          if payload.fetch('types').include?('administrative_area_level_1')
            geo.region = payload.fetch('short_name')
          end
        end

        def self._parse_country(geo, payload)
          if payload.fetch('types').include?('country')
            geo.country = payload.fetch('long_name')
            geo.country_code = payload.fetch('short_name')
          end
        end

        def self._parse_postal_code(geo, payload)
          if payload.fetch('types').include?('postal_code')
            geo.postal_code = payload.fetch('short_name')
          end
        end

        def self._parse_query(geo, payload, detected_types, query_parts)
          return if (%w(street_address route) & detected_types).any?

          if (payload.fetch('types') & detected_types).any?
            query_parts << payload.fetch('short_name')
            geo.query = query_parts.join(', ')
          end
        end
      end
    end
  end
end
