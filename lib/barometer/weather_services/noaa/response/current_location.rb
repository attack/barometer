module Barometer
  module WeatherService
    class Noaa
      class Response
        class CurrentLocation < WeatherService::Response::Location
          def initialize(payload, response)
            super(payload)
            @location = response.location
          end

          private

          attr_reader :location

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

          def latitude
            location.latitude
          end

          def longitude
            location.longitude
          end
        end
      end
    end
  end
end
