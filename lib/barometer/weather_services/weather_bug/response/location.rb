module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class Location
          def initialize(payload)
            @payload = payload
            @location = Data::Location.new
          end

          def parse
            location.city = city
            location.state_code = state_code
            location.zip_code = zip_code

            location
          end

          private

          attr_reader :payload, :location

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
