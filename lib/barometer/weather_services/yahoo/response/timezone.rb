module Barometer
  module WeatherService
    class Yahoo
      class Response
        class TimeZone < WeatherService::Response::TimeZone
          private

          def time_zone
            payload.using(/ ([A-Z]+)$/).fetch('item', 'pubDate')
          end
        end
      end
    end
  end
end
