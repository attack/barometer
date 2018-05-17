module Barometer
  module Query
    module Service
      class GoogleGeocode
        class Api < Utils::Api
          def url
            'https://maps.googleapis.com/maps/api/geocode/json'
          end

          def params
            format_params
          end

          def unwrap_nodes
            ['results', 0]
          end

          private

          def format_params
            params = { sensor: 'false' }
            params[:key] = key if key
            params[:region] = query.geo.country_code if query.geo.country_code

            if query.format == :coordinates
              params[:latlng] = query.q.dup
            else
              params[:address] = query.q.dup
            end
            params
          end

          def key
            @key ||= Barometer::Support::KeyFileParser.find(:google, :apikey)
          end
        end
      end
    end
  end
end
