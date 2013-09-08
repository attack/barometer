module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class FullTimeZone < WeatherService::Response::TimeZone
          def parse
            payload.fetch_each('simpleforecast', 'forecastday') do |forecast_payload|
              timezone = timezone(forecast_payload)
              return Data::Zone.new(timezone) if timezone
            end
          end

          private

          def timezone(forecast_payload)
            forecast_payload.fetch('date', 'tz_long')
          end
        end
      end
    end
  end
end
