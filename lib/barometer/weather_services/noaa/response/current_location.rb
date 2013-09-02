module Barometer
  module WeatherService
    class Noaa
      class Response
        class CurrentLocation
          def initialize(payload, response)
            @payload = payload
            @location = response.location
          end

          def parse
            location.name = name
            location.city = city
            location.state_code = state_code
            location.country_code = country_code

            location
          end

          private

          attr_reader :payload, :location

          def name
            payload.fetch('location')
          end

          def city
            payload.using(/^(.*?),/).fetch('location')
          end

          def state_code
            payload.using(/,(.*?)$/).fetch('location')
          end

          def country_code
            'US'
          end
        end
      end
    end
  end
end
