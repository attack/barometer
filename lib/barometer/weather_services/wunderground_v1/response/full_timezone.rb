module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class FullTimeZone
          def initialize(payload)
            @payload = payload
          end

          def parse
            payload.fetch_each('simpleforecast', 'forecastday') do |forecast_payload|
              timezone = timezone(forecast_payload)
              return timezone if timezone
            end
          end

          private

          attr_reader :payload

          def timezone(forecast_payload)
            forecast_payload.fetch('date', 'tz_long')
          end
        end
      end
    end
  end
end
