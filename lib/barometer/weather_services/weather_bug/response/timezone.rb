module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class TimeZone
          def initialize(payload)
            @payload = payload
          end

          def parse
            payload.fetch('ob_date', 'time_zone', '@abbrv')
          end

          private

          attr_reader :payload
        end
      end
    end
  end
end
