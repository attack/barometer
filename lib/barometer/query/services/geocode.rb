module Barometer
  module Query
    module Service
      class Geocode
        def self.fetch(query)
          converted_query = query.get_conversion(:short_zipcode, :zipcode, :postalcode, :coordinates, :icao, :geocode)
          return unless converted_query
          puts "geocoding: #{converted_query.q}" if Barometer::debug?

          location =  Barometer::Http::Get.call(
            'http://maps.googleapis.com/maps/api/geocode/json',
            _format_params(converted_query)
          )

          Barometer::JsonReader.parse(location, 'results') do |result|
            Data::Geo.new(result.first)
          end
        end

        def self._format_params(query)
          params = {}
          params[:region] = query.country_code if query.country_code
          params[:sensor] = 'false'

          if query.format == :coordinates
            params[:latlng] = query.q.dup
          else
            params[:address] = query.q.dup
          end
          params
        end
      end
    end
  end
end
