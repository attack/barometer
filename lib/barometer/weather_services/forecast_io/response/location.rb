module Barometer
  module WeatherService
    class ForecastIo
      class Response
        class Location
          def initialize(payload)
            @payload = payload
            @location = Data::Location.new
          end

          def parse
            location.latitude = latitude
            location.longitude = longitude

            location
          end

          private

          attr_reader :payload, :location

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
