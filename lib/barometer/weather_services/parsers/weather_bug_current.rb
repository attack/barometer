module Barometer
  module Parser
    class WeatherBugCurrent
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse(payload)
        _parse_time(payload)
        _parse_current(payload)
        _parse_sun(payload)
        _parse_station(payload)

        @measurement
      end

      private

      def _parse_current(payload)
        @measurement.current.tap do |current|
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
        rise_h = payload.fetch('sunrise', 'hour', '@hour_24').to_i
        rise_m = payload.fetch('sunrise', 'minute', '@number').to_i
        rise_s = payload.fetch('sunrise', 'second', '@number').to_i
        @measurement.current.sun.rise = Data::LocalTime.new(rise_h, rise_m, rise_s)

        set_h = payload.fetch('sunset', 'hour', '@hour_24').to_i
        set_m = payload.fetch('sunset', 'minute', '@number').to_i
        set_s = payload.fetch('sunset', 'second', '@number').to_i
        @measurement.current.sun.set = Data::LocalTime.new(set_h, set_m, set_s)
      end

      def _parse_station(payload)
        @measurement.station.tap do |station|
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
        @measurement.timezone = payload.fetch('ob_date', 'time_zone', '@abbrv')

        datetime = [
          payload.fetch('ob_date', 'year', '@number').to_i,
          payload.fetch('ob_date', 'month', '@number').to_i,
          payload.fetch('ob_date', 'day', '@number').to_i,
          payload.fetch('ob_date', 'hour', '@hour_24').to_i,
          payload.fetch('ob_date', 'minute', '@number').to_i,
          payload.fetch('ob_date', 'second', '@number').to_i
        ]
        @measurement.published_at = datetime
        @measurement.current.starts_at = datetime
      end
    end
  end
end
