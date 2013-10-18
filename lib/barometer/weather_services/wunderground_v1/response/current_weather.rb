module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class CurrentWeather
          def initialize(payload)
            @payload = payload
            @current = Barometer::Response::Current.new
          end

          def parse
            current.observed_at = observed_at, '%B %e, %l:%M %p %Z'
            current.stale_at = stale_at
            current.humidity = humidity
            current.condition = condition
            current.icon = icon
            current.temperature = temperature
            current.dew_point = dew_point
            current.wind_chill = wind_chill
            current.heat_index = heat_index
            current.wind = wind
            current.visibility = visibility
            current.pressure = pressure

            current
          end

          private

          attr_reader :payload, :current

          def units
            payload.units
          end

          def observed_at
            payload.fetch('local_time')
          end

          def stale_at
            return unless current.observed_at
            utc_observed_at = current.observed_at.utc
            Time.utc(
              utc_observed_at.year, utc_observed_at.month, utc_observed_at.day,
              utc_observed_at.hour + 1, 0, 0
            )
          end

          def humidity
            payload.fetch('relative_humidity')
          end

          def condition
            payload.fetch('weather')
          end

          def icon
            payload.fetch('icon')
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

          def heat_index
            [units, payload.fetch('heat_index_c'), payload.fetch('heat_index_f')]
          end

          def wind
            [:imperial, payload.fetch('wind_mph').to_i, payload.fetch('wind_degrees').to_i]
          end

          def visibility
            [units, payload.fetch('visibility_km'), payload.fetch('visibility_mi')]
          end

          def pressure
            [units, payload.fetch('pressure_mb'), payload.fetch('pressure_in')]
          end
        end
      end
    end
  end
end
