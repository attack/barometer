module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class Station < WeatherService::Response::Location
          private

          def id
            payload.fetch('station_id')
          end

          def name
            payload.fetch('station')
          end

          def city
            payload.using(/^([\w ]*?),/).fetch('city_state')
          end

          def state_code
            payload.using(/^[\w ^,]*?,([\w ^,]*)/).fetch('city_state')
          end

          def country
            payload.fetch('country')
          end

          def zip_code
            payload.fetch('city_state', '@zipcode')
          end

          def latitude
            payload.fetch('latitude')
          end

          def longitude
            payload.fetch('longitude')
          end
        end
      end
    end
  end
end
