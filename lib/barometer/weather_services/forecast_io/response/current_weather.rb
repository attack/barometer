module Barometer
  module WeatherService
    class ForecastIo
      class Response
        class CurrentWeather
          def initialize(payload)
            @payload = payload
            @current = Barometer::Response::Current.new
          end

          def parse
            current.observed_at = observed_at
            current.humidity = humidity
            current.condition = condition
            current.icon = icon
            current.temperature = temperature
            current.dew_point = dew_point
            current.wind = wind
            current.pressure = pressure
            current.visibility = visibility

            current
          end

          private

          attr_reader :payload, :current

          def units
            payload.units
          end

          def observed_at
            Time.at(payload.fetch('currently', 'time').to_i)
          end

          def humidity
            payload.fetch('currently', 'humidity') * 100
          end

          def condition
            payload.fetch('currently', 'summary')
          end

          def icon
            payload.fetch('currently', 'icon')
          end

          def temperature
            [units, payload.fetch('currently', 'temperature')]
          end

          def dew_point
            [units, payload.fetch('currently', 'dewPoint')]
          end

          def wind
            [units, convert_metre_per_second(payload.fetch('currently', 'windSpeed')), payload.fetch('currently', 'windBearing').to_i]
          end

          def pressure
            [:metric, payload.fetch('currently', 'pressure')]
          end

          def visibility
            [units, payload.fetch('currently', 'visibility')]
          end

          private

          def convert_metre_per_second(value)
            value.to_f * 60 * 60 / 1000
          end
        end
      end
    end
  end
end
