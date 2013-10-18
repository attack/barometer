module Barometer
  module WeatherService
    class Noaa
      class Response
        class CurrentWeather
          def initialize(payload)
            @payload = payload
            @current = Barometer::Response::Current.new
          end

          def parse
            current.observed_at = observed_at, '%a, %d %b %Y %H:%M:%S %z'
            current.stale_at = stale_at
            current.humidity = humidity
            current.condition = condition
            current.icon = icon
            current.temperature = temperature
            current.dew_point = dew_point
            current.wind_chill = wind_chill
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
            payload.fetch('observation_time_rfc822')
          end

          def stale_at
            current.observed_at + (60 * 60 * 1) if current.observed_at
          end

          def humidity
            payload.fetch('relative_humidity')
          end

          def condition
            payload.fetch('weather')
          end

          def icon
            payload.using(/(.*).(jpg|png)$/).fetch('icon_url_name')
          end

          def temperature
            [units, payload.fetch('temp_c'), payload.fetch('temp_f')]
          end

          def dew_point
            [units, payload.fetch('dewpoint_c'), payload.fetch('dewpoint_f')]
          end

          def wind_chill
            [units, payload.fetch('windchill_c'), payload.fetch('windchill_f')]
          end

          def wind
            [:imperial, payload.fetch('wind_mph').to_f, payload.fetch('wind_degrees').to_i]
          end

          def pressure
            [units, payload.fetch('pressure_mb'), payload.fetch('pressure_in')]
          end

          def visibility
            [:imperial, payload.fetch('visibility_mi').to_f]
          end
        end
      end
    end
  end
end
