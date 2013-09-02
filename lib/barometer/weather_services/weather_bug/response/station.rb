module Barometer
  module WeatherService
    class WeatherBug
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
            station.country = country
            station.zip_code = zip_code
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
            payload.fetch('station')
          end

          def city
            payload.using(/^([\w ]*?),/).fetch('city_state')
          end

          def state_code
            payload.using(/^[\w ^,]*?,([\w ^,]*)/).fetch('city_state')
          end

          def country
            payload.fetch('country')
          end

          def zip_code
            payload.fetch('barometer:station_zipcode')
          end

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
