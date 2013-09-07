module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class Location < WeatherService::Response::Location
          private

          def name
            payload.fetch('display_location', 'full')
          end

          def city
            payload.fetch('display_location', 'city')
          end

          def state_code
            payload.fetch('display_location', 'state')
          end

          def state_name
            payload.fetch('display_location', 'state_name')
          end

          def zip_code
            payload.fetch('display_location', 'zip')
          end

          def country_code
            payload.fetch('display_location', 'country')
          end

          def latitude
            payload.fetch('display_location', 'latitude')
          end

          def longitude
            payload.fetch('display_location', 'longitude')
          end
        end
      end
    end
  end
end
