module Barometer
  module WeatherService
    class ForecastIo
      class Response
        class TimeZone
          def initialize(payload)
            @payload = payload
          end

          def parse
            @payload.fetch('timezone')
          end
        end
      end
    end
  end
end
