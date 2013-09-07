module Barometer
  module WeatherService
    class Noaa
      class Response
        class CurrentStation < WeatherService::Response::Location
          def initialize(payload, response)
            super(payload)
            @station = response.station
          end

          private

          attr_reader :station

          def id
            payload.fetch('station_id')
          end

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
            station.latitude
          end

          def longitude
            station.longitude
          end
        end
      end
    end
  end
end
