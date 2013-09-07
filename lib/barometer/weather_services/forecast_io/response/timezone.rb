module Barometer
  module WeatherService
    class ForecastIo
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
            payload.fetch('timezone')
          end
        end
      end
    end
  end
end
