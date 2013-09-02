module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class TimeHelper
          def initialize(payload, timezone)
            @payload = payload
            @timezone = timezone
          end

          def parse(key)
            return unless local_time(key)
            timezone.local_to_utc(local_time(key))
          end

          private

          attr_reader :payload, :timezone, :key

          def local_time(key)
            @key = key
            @local_time ||= Utils::Time.parse(year, month, day, hour, minute, second)
          end

          def year
            payload.fetch(key, 'year', '@number')
          end

          def month
            payload.fetch(key, 'month', '@number')
          end

          def day
            payload.fetch(key, 'day', '@number')
          end

          def hour
            payload.fetch(key, 'hour', '@hour_24')
          end

          def minute
            payload.fetch(key, 'minute', '@number')
          end

          def second
            payload.fetch(key, 'second', '@number')
          end
        end
      end
    end
  end
end
