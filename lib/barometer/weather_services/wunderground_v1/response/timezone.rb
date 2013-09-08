module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class TimeZone
          def initialize(payload)
            @payload = payload
          end

          def parse
            Data::Zone.new(time_zone)
          end

          private

          attr_reader :payload

          def time_zone
            payload.using(/ (\w*)$/).fetch('local_time')
          end
        end
      end
    end
  end
end
