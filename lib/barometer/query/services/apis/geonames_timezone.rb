module Barometer
  module Query
    module Service
      class GeonamesTimezone
        class Api < Utils::Api
          def initialize(latitude, longitude)
            @latitude = latitude
            @longitude = longitude
          end

          def url
            'http://ws.geonames.org/timezone'
          end

          def params
            { lat: @latitude, lng: @longitude }
          end

          def unwrap_nodes
            ['geonames', 'timezone']
          end
        end
      end
    end
  end
end
