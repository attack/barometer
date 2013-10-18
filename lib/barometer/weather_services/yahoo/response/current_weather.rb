require 'barometer/weather_services/yahoo/response/sun'
require 'ostruct'

module Barometer
  module WeatherService
    class Yahoo
      class Response
        class CurrentWeather
          def initialize(payload, timezone)
            @payload = payload
            @timezone = timezone
            @current = Barometer::Response::Current.new # needs query or metric
          end

          def parse
            current.observed_at = observed_at, '%a, %d %b %Y %l:%M %P %Z'
            current.stale_at = stale_at
            current.condition = condition
            current.icon = icon
            current.temperature = temperature
            current.humidity = humidity
            current.pressure = pressure
            current.visibility = visibility
            current.wind_chill = wind_chill
            current.wind = wind
            current.sun = Yahoo::Response::Sun.new(payload, base_time).parse

            current
          end

          private

          attr_reader :payload, :timezone, :current

          def units
            payload.units
          end

          def base_time
            OpenStruct.new(:timezone => timezone, :base => current.observed_at)
          end

          def observed_at
            payload.fetch('item', 'pubDate')
          end

          def stale_at
            (current.observed_at + (60 * 60 * 1)) if current.observed_at
          end

          def condition
            payload.fetch('item', 'condition', '@text')
          end

          def icon
            payload.fetch('item', 'condition', '@code')
          end

          def temperature
            [units, payload.fetch('item', 'condition', '@temp')]
          end

          def humidity
            payload.fetch('atmosphere', '@humidity')
          end

          def pressure
            [units, payload.fetch('atmosphere', '@pressure')]
          end

          def visibility
            [units, payload.fetch('atmosphere', '@visibility')]
          end

          def wind_chill
            [units, payload.fetch('wind', '@chill')]
          end

          def wind
            [units, payload.fetch('wind', '@speed'), payload.fetch('wind', '@direction').to_f]
          end
        end
      end
    end
  end
end
