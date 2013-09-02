module Barometer
  module WeatherService
    class Noaa
      class Response
        class TimeZone
          def initialize(payload)
            @payload = payload
          end

          def parse
            payload.using(/ ([A-Z]*)$/).fetch('observation_time')
          end

          private

          attr_reader :payload
        end
      end
    end
  end
end
