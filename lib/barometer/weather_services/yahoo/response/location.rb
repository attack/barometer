module Barometer
  module WeatherService
    class Yahoo
      class Response
        class Location
          def initialize(payload)
            @payload = payload
            @location = Data::Location.new
          end

          def parse
            location.city = city
            location.state_code = state_code
            location.country_code = country_code
            location.latitude = latitude
            location.longitude = longitude

            location
          end

          private

          attr_reader :payload, :location

          def city
            payload.fetch('location', '@city')
          end

          def state_code
            payload.fetch('location', '@region')
          end

          def country_code
            payload.fetch('location', '@country')
          end

          def latitude
            payload.fetch('item', 'lat')
          end

          def longitude
            payload.fetch('item', 'long')
          end
        end
      end
    end
  end
end
