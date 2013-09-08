module Barometer
  module WeatherService
    class Yahoo
      class Response
        class Location
          def initialize(payload)
            @payload = payload
          end

          def parse
            Data::Location.new(
              :city => city,
              :state_code => state_code,
              :country_code => country_code,
              :latitude => latitude,
              :longitude => longitude
            )
          end

          private

          attr_reader :payload

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
