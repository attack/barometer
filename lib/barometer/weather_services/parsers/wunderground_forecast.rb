module Barometer
  module Parser
    class WundergroundForecast
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse(payload)
        _build_forecasts(payload)
        _parse_sun(payload)

        @measurement
      end

      private

      def _parse_sun(payload)
        rise_h = payload.fetch('moon_phase', 'sunrise', 'hour').to_i
        rise_m = payload.fetch('moon_phase', 'sunrise', 'minute').to_i
        @measurement.current.sun.rise = Data::LocalTime.new(rise_h, rise_m, 0)

        set_h = payload.fetch('moon_phase', 'sunset', 'hour').to_i
        set_m = payload.fetch('moon_phase', 'sunset', 'minute').to_i
        @measurement.current.sun.set = Data::LocalTime.new(set_h, set_m, 0)
      end

      def _parse_zone(payload)
        @measurement.timezone = payload.fetch('date', 'tz_long')
      end

      def _build_forecasts(payload)
        payload.fetch_each("simpleforecast", "forecastday") do |forecast_payload|
          @measurement.build_forecast do |forecast_measurement|
            _parse_zone(forecast_payload)

            forecast_measurement.starts_at = forecast_payload.fetch('date', 'pretty'), "%I:%M %p %Z on %B %d, %Y"
            one_day_minus_one_second = Rational((60 * 60 * 24 - 1),(60 * 60 * 24))
            forecast_measurement.ends_at = Data::LocalDateTime.parse(forecast_measurement.starts_at.to_dt + one_day_minus_one_second)

            forecast_measurement.icon = forecast_payload.fetch('icon')
            forecast_measurement.pop = forecast_payload.fetch('pop').to_i
            forecast_measurement.high = [forecast_payload.fetch('high', 'celsius'), forecast_payload.fetch('high', 'fahrenheit')]
            forecast_measurement.low = [forecast_payload.fetch('low', 'celsius'), forecast_payload.fetch('low', 'fahrenheit')]
            forecast_measurement.sun = @measurement.current.sun
          end
        end
      end
    end
  end
end
