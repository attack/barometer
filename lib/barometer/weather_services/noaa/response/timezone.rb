module Barometer
  module WeatherService
    class Noaa
      class Response
        class TimeZone < WeatherService::Response::TimeZone
          private

          def time_zone
            payload.using(/ ([A-Z]*)$/).fetch('observation_time')
          end
        end
      end
    end
  end
end
