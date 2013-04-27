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
        @measurement.current.sun = Barometer::Data::Sun.new(
          _time(payload, 'sunrise'), _time(payload, 'sunset')
        )
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
