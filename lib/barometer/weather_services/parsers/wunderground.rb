module Barometer
  module Parser
    class Wunderground
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse_current(payload)
        _parse_current(payload)
        _parse_station(payload)
        _parse_location(payload)
        _parse_time(payload)

        @measurement
      end

      def parse_forecast(payload)
        _build_forecasts(payload)
        _parse_sun(payload)

        @measurement
      end

      private

      def _parse_current(payload)
        @measurement.current.tap do |current|
          current.starts_at = payload.fetch('local_time'), "%B %e, %l:%M %p %Z"

          current.humidity = payload.fetch('relative_humidity')
          current.condition = payload.fetch('weather')
          current.icon = payload.fetch('icon')
          current.temperature = [payload.fetch('temp_c'), payload.fetch('temp_f')]
          current.dew_point = [payload.fetch('dewpoint_c'), payload.fetch('dewpoint_f')]
          current.wind_chill = [payload.fetch('windchill_c'), payload.fetch('windchill_f')]
          current.heat_index = [payload.fetch('heat_index_c'), payload.fetch('heat_index_f')]
          current.wind = [:imperial, payload.fetch('wind_mph').to_i, payload.fetch('wind_degrees').to_i]
          current.visibility = [payload.fetch('visibility_km'), payload.fetch('visibility_mi')]
          current.pressure = [payload.fetch('pressure_mb'), payload.fetch('pressure_in')]
        end
      end

      def _parse_sun(payload)
        rise_h = payload.fetch('moon_phase', 'sunrise', 'hour').to_i
        rise_m = payload.fetch('moon_phase', 'sunrise', 'minute').to_i
        @measurement.current.sun.rise = Data::LocalTime.new(rise_h, rise_m, 0)

        set_h = payload.fetch('moon_phase', 'sunset', 'hour').to_i
        set_m = payload.fetch('moon_phase', 'sunset', 'minute').to_i
        @measurement.current.sun.set = Data::LocalTime.new(set_h, set_m, 0)
      end

      def _parse_station(payload)
        @measurement.station.tap do |station|
          station.id = payload.fetch('station_id')
          station.name = payload.fetch('observation_location', 'full')
          station.city = payload.fetch('observation_location', 'city')
          station.state_code = payload.fetch('observation_location', 'state')
          station.country_code = payload.fetch('observation_location', 'country')
          station.latitude = payload.fetch('observation_location', 'latitude')
          station.longitude = payload.fetch('observation_location', 'longitude')
        end
      end

      def _parse_location(payload)
        @measurement.location.tap do |location|
          if geo = @query.geo
            location.city = geo.locality
            location.state_code = geo.region
            location.country = geo.country
            location.country_code = geo.country_code
            location.latitude = geo.latitude
            location.longitude = geo.longitude
          else
            location.name = payload.fetch('display_location', 'full')
            location.city = payload.fetch('display_location', 'city')
            location.state_code = payload.fetch('display_location', 'state')
            location.state_name = payload.fetch('display_location', 'state_name')
            location.zip_code = payload.fetch('display_location', 'zip')
            location.country_code = payload.fetch('display_location', 'country')
            location.latitude = payload.fetch('display_location', 'latitude')
            location.longitude = payload.fetch('display_location', 'longitude')
          end
        end
      end

      def _parse_time(payload)
        @measurement.timezone = payload.using(/ (\w*)$/).fetch('local_time')
        @measurement.published_at = payload.fetch('observation_time_rfc822'), "%a, %d %b %Y %H:%M:%S %Z"
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
