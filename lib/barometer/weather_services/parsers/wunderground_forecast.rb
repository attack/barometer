module Barometer
  module Parser
    class WundergroundForecast
      def initialize(response, query)
        @response = response
        @query = query
      end

      def parse(payload)
        _parse_zone(payload)
        _parse_sun(payload)
        _build_forecasts(payload)

        @response
      end

      private

      def _parse_zone(payload)
        payload.fetch_each("simpleforecast", "forecastday") do |forecast_payload|
          timezone = forecast_payload.fetch('date', 'tz_long')
          @response.timezone = timezone if timezone
          break
        end
      end

      def _parse_sun(payload)
        rise_h = payload.fetch('moon_phase', 'sunrise', 'hour')
        rise_m = payload.fetch('moon_phase', 'sunrise', 'minute')
        rise_utc = Utils::Time.utc_from_base_plus_local_time(
          @response.timezone, @response.current.observed_at, rise_h, rise_m
        )

        set_h = payload.fetch('moon_phase', 'sunset', 'hour')
        set_m = payload.fetch('moon_phase', 'sunset', 'minute')
        set_utc = Utils::Time.utc_from_base_plus_local_time(
          @response.timezone, @response.current.observed_at, set_h, set_m
        )

        @response.current.sun = Data::Sun.new(rise_utc, set_utc)
      end

      def _build_forecasts(payload)
        payload.fetch_each("simpleforecast", "forecastday") do |forecast_payload|
          @response.build_forecast do |forecast_response|
            forecast_response.starts_at = forecast_payload.fetch('date', 'pretty'), "%I:%M %p %Z on %B %d, %Y"
            forecast_response.ends_at = Utils::Time.add_one_day(forecast_response.starts_at)

            forecast_response.icon = forecast_payload.fetch('icon')
            forecast_response.pop = forecast_payload.fetch('pop')
            forecast_response.high = [forecast_payload.fetch('high', 'celsius'), forecast_payload.fetch('high', 'fahrenheit')]
            forecast_response.low = [forecast_payload.fetch('low', 'celsius'), forecast_payload.fetch('low', 'fahrenheit')]

            rise_utc = Utils::Time.utc_merge_base_plus_time(forecast_response.starts_at, @response.current.sun.rise)
            set_utc = Utils::Time.utc_merge_base_plus_time(forecast_response.ends_at, @response.current.sun.set)
            forecast_response.sun = Data::Sun.new(rise_utc, set_utc)
          end
        end
      end
    end
  end
end
