module Barometer
  module WeatherService
    class Yahoo
      class Response
        class TimeZone
          def initialize(payload)
            @payload = payload
          end

          def parse
            @payload.using(/ ([A-Z]+)$/).fetch('item', 'pubDate')
          end
        end
      end
    end
  end
end
