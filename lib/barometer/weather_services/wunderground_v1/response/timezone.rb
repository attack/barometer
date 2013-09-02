module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class TimeZone
          def initialize(payload)
            @payload = payload
          end

          def parse
            payload.using(/ (\w*)$/).fetch('local_time')
          end

          private

          attr_reader :payload
        end
      end
    end
  end
end
