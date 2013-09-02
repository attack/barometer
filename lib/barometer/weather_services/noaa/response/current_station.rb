module Barometer
  module WeatherService
    class Noaa
      class Response
        class CurrentStation
          def initialize(payload, response)
            @payload = payload
            @station = response.station
          end

          def parse
            station.id = id
            station.name = name
            station.city = city
            station.state_code = state_code
            station.country_code = country_code

            station
          end

          private

          attr_reader :payload, :station

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
        end
      end
    end
  end
end
