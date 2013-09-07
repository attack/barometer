module Barometer
  module WeatherService
    class Yahoo
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
            payload.using(/ ([A-Z]+)$/).fetch('item', 'pubDate')
          end
        end
      end
    end
  end
end
