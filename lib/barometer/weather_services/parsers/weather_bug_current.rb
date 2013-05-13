module Barometer
  module Parser
    class WeatherBugCurrent
      def initialize(response)
        @response = response
      end

      def parse(payload)
        _parse_time(payload)
        _parse_current(payload)
        _parse_sun(payload)
        _parse_station(payload)

        @response
      end

      private

      def _parse_current(payload)
        @response.current.tap do |current|
          current.humidity = payload.fetch('humidity')
          current.condition = payload.fetch('current_condition')
          current.icon = payload.fetch('barometer:icon')
          current.temperature = [payload.fetch('temp')]
          current.dew_point = [payload.fetch('dew_point')]
          current.wind_chill = [payload.fetch('feels_like')]
          current.wind = [payload.fetch('wind_speed'), payload.fetch('wind_direction_degrees')]
          current.pressure = [payload.fetch('pressure')]
        end
      end

      def _parse_sun(payload)
        @response.current.sun = Barometer::Data::Sun.new(
          _time(payload, 'sunrise'), _time(payload, 'sunset')
        )
      end

      def _parse_station(payload)
        @response.station.tap do |station|
          station.id = payload.fetch('station_id')
          station.name = payload.fetch('station')
          station.city = payload.using(/^([\w ]*?),/).fetch('city_state')
          station.state_code = payload.using(/^[\w ^,]*?,([\w ^,]*)/).fetch('city_state')
          station.country = payload.fetch('country')
          station.zip_code = payload.fetch('barometer:station_zipcode')
          station.latitude = payload.fetch('latitude')
          station.longitude = payload.fetch('longitude')
        end
      end

      def _parse_time(payload)
        @response.timezone = payload.fetch('ob_date', 'time_zone', '@abbrv')
        @response.current.observed_at = _time(payload, 'ob_date')
        @response.current.stale_at = Barometer::Utils::Time.add_one_hour(@response.current.observed_at)
      end

      def _time(payload, key)
        values = [
          payload.fetch(key, 'year', '@number'),
          payload.fetch(key, 'month', '@number'),
          payload.fetch(key, 'day', '@number'),
          payload.fetch(key, 'hour', '@hour_24'),
          payload.fetch(key, 'minute', '@number'),
          payload.fetch(key, 'second', '@number')
        ]

        local_time = Barometer::Utils::Time.parse(*values)
        return unless local_time
        @response.timezone.local_to_utc(local_time)
      end
    end
  end
end
