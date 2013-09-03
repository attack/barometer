require 'barometer/weather_services/weather_bug/response/time_helper'
require 'barometer/weather_services/weather_bug/response/sun'

module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class CurrentWeather
          def initialize(payload, timezone)
            @payload = payload
            @timezone = timezone
            @current = Barometer::Response::Current.new
          end

          def parse
            current.observed_at = observed_at
            current.stale_at = stale_at
            current.humidity = humidity
            current.condition = condition
            current.icon = icon
            current.temperature = temperature
            current.dew_point = dew_point
            current.wind_chill = wind_chill
            current.wind = wind
            current.pressure = pressure
            current.sun = WeatherBug::Response::Sun.new(payload, timezone).parse

            current
          end

          private

          attr_reader :payload, :timezone, :current

          def observed_at
            @observed_at ||= TimeHelper.new(payload, timezone).parse('ob_date')
          end

          def stale_at
            Utils::Time.add_one_hour(observed_at)
          end

          def humidity
            payload.fetch('humidity')
          end

          def condition
            payload.fetch('current_condition')
          end

          def icon
            payload.fetch('barometer:icon')
          end

          def temperature
            [payload.fetch('temp')]
          end

          def dew_point
            [payload.fetch('dew_point')]
          end

          def wind_chill
            [payload.fetch('feels_like')]
          end

          def wind
            [payload.fetch('wind_speed'), payload.fetch('wind_direction_degrees')]
          end

          def pressure
            [payload.fetch('pressure')]
          end
        end
      end
    end
  end
end
