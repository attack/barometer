module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class Location < WeatherService::Response::Location
          private

          def city
            payload.fetch('location', 'city')
          end

          def state_code
            payload.fetch('location', 'state')
          end

          def zip_code
            payload.fetch('location', 'zip')
          end
        end
      end
    end
  end
end
