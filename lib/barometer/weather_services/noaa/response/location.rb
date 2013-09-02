module Barometer
  module WeatherService
    class Noaa
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
            payload.fetch('location', 'point', '@latitude')
          end

          def longitude
            payload.fetch('location', 'point', '@longitude')
          end
        end
      end
    end
  end
end
