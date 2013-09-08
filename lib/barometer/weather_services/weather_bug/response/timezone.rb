module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class TimeZone < WeatherService::Response::TimeZone
          private

          def time_zone
            payload.fetch('ob_date', 'time_zone', '@abbrv')
          end
        end
      end
    end
  end
end
