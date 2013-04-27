module Barometer
  module Parser
    class WundergroundForecast
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse(payload)
        _parse_zone(payload)
        _parse_sun(payload)
        _build_forecasts(payload)

        @measurement
      end

      private

      def _parse_zone(payload)
        payload.fetch_each("simpleforecast", "forecastday") do |forecast_payload|
          timezone = forecast_payload.fetch('date', 'tz_long')
          @measurement.timezone = timezone if timezone
          break
        end
      end

      def _parse_sun(payload)
        rise_h = payload.fetch('moon_phase', 'sunrise', 'hour')
        rise_m = payload.fetch('moon_phase', 'sunrise', 'minute')
        rise_utc = Helpers::Time.utc_from_base_plus_local_time(
          @measurement.timezone, @measurement.current.observed_at, rise_h, rise_m
        )

        set_h = payload.fetch('moon_phase', 'sunset', 'hour')
        set_m = payload.fetch('moon_phase', 'sunset', 'minute')
        set_utc = Helpers::Time.utc_from_base_plus_local_time(
          @measurement.timezone, @measurement.current.observed_at, set_h, set_m
        )

        @measurement.current.sun = Data::Sun.new(rise_utc, set_utc)
      end

      def _build_forecasts(payload)
        payload.fetch_each("simpleforecast", "forecastday") do |forecast_payload|
          @measurement.build_forecast do |forecast_measurement|
            forecast_measurement.starts_at = forecast_payload.fetch('date', 'pretty'), "%I:%M %p %Z on %B %d, %Y"
            forecast_measurement.ends_at = Helpers::Time.add_one_day(forecast_measurement.starts_at)

            forecast_measurement.icon = forecast_payload.fetch('icon')
            forecast_measurement.pop = forecast_payload.fetch('pop')
            forecast_measurement.high = [forecast_payload.fetch('high', 'celsius'), forecast_payload.fetch('high', 'fahrenheit')]
            forecast_measurement.low = [forecast_payload.fetch('low', 'celsius'), forecast_payload.fetch('low', 'fahrenheit')]

            rise_utc = Helpers::Time.utc_merge_base_plus_time(forecast_measurement.starts_at, @measurement.current.sun.rise)
            set_utc = Helpers::Time.utc_merge_base_plus_time(forecast_measurement.ends_at, @measurement.current.sun.set)
            forecast_measurement.sun = Data::Sun.new(rise_utc, set_utc)
          end
        end
      end
    end
  end
end
