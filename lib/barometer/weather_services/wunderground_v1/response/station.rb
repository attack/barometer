module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class Station < WeatherService::Response::Location
          private

          def id
            payload.fetch('station_id')
          end

          def name
            payload.fetch('observation_location', 'full')
          end

          def city
            payload.fetch('observation_location', 'city')
          end

          def state_code
            payload.fetch('observation_location', 'state')
          end

          def country_code
            payload.fetch('observation_location', 'country')
          end

          def latitude
            payload.fetch('observation_location', 'latitude')
          end

          def longitude
            payload.fetch('observation_location', 'longitude')
          end
        end
      end
    end
  end
end
