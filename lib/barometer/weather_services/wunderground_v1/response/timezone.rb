module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class TimeZone < WeatherService::Response::TimeZone
          private

          def time_zone
            payload.using(/ (\w*)$/).fetch('local_time')
          end
        end
      end
    end
  end
end
