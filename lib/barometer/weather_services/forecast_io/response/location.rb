module Barometer
  module WeatherService
    class ForecastIo
      class Response
        class Location < WeatherService::Response::Location
          private

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
