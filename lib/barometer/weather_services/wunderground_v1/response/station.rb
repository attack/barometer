module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class Station
          def initialize(payload)
            @payload = payload
            @station = Data::Location.new
          end

          def parse
            station.id = id
            station.name = name
            station.city = city
            station.state_code = state_code
            station.country_code = country_code
            station.latitude = latitude
            station.longitude = longitude

            station
          end

          private

          attr_reader :payload, :station

          def id
            payload.fetch('station_id')
          end

          def name
            payload.fetch('observation_location', 'full')
          end

          def city
            payload.fetch('observation_location', 'city')
          end

          def state_code
            payload.fetch('observation_location', 'state')
          end

          def country_code
            payload.fetch('observation_location', 'country')
          end

          def latitude
            payload.fetch('observation_location', 'latitude')
          end

          def longitude
            payload.fetch('observation_location', 'longitude')
          end
        end
      end
    end
  end
end
