module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class Sun
          def initialize(payload, timezone, response)
            @payload = payload
            @timezone = timezone
            @response = response
          end

          def parse
            Data::Sun.new(rise: utc_rise_time, set: utc_set_time)
          end

          private

          attr_reader :payload, :timezone, :response

          def utc_rise_time
            return unless response.current
            Utils::Time.utc_from_base_plus_local_time(
              timezone, response.current.observed_at, rise_hour, rise_min
            )
          end

          def utc_set_time
            return unless response.current
            Utils::Time.utc_from_base_plus_local_time(
              timezone, response.current.observed_at, set_hour, set_min
            )
          end

          def rise_hour
            payload.fetch('moon_phase', 'sunrise', 'hour')
          end

          def rise_min
            payload.fetch('moon_phase', 'sunrise', 'minute')
          end

          def set_hour
            payload.fetch('moon_phase', 'sunset', 'hour')
          end

          def set_min
            payload.fetch('moon_phase', 'sunset', 'minute')
          end
        end
      end
    end
  end
end
