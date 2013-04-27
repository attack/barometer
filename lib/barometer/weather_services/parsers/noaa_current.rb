module Barometer
  module Parser
    class NoaaCurrent
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse(payload)
        _parse_time(payload)
        _parse_current(payload)
        _parse_station(payload)
        _parse_location(payload)

        @measurement
      end

      private

      def _parse_time(payload)
        @measurement.timezone = payload.using(/ ([A-Z]*)$/).fetch('observation_time')
      end

      def _parse_current(payload)
        @measurement.current.tap do |current|
          current.observed_at = payload.fetch('observation_time_rfc822'), '%a, %d %b %Y %H:%M:%S %z'
          current.stale_at = current.observed_at + (60 * 60 * 1) if current.observed_at

          current.humidity = payload.fetch('relative_humidity')
          current.condition = payload.fetch('weather')
          current.icon = payload.using(/(.*).(jpg|png)$/).fetch('icon_url_name')
          current.temperature = [payload.fetch('temp_c'), payload.fetch('temp_f')]
          current.dew_point = [payload.fetch('dewpoint_c'), payload.fetch('dewpoint_f')]
          current.wind_chill = [payload.fetch('windchill_c'), payload.fetch('windchill_f')]
          current.wind = [:imperial, payload.fetch('wind_mph').to_f, payload.fetch('wind_degrees').to_i]
          current.pressure = [payload.fetch('pressure_mb'), payload.fetch('pressure_in')]
          current.visibility = [:imperial, payload.fetch('visibility_mi').to_f]
        end
      end

      def _parse_station(payload)
        @measurement.station.tap do |station|
          station.id = payload.fetch('station_id')
          station.name = payload.fetch('location')
          station.city = payload.using(/^(.*?),/).fetch('location')
          station.state_code = payload.using(/,(.*?)$/).fetch('location')
          station.country_code = 'US'
        end
      end

      def _parse_location(payload)
        @measurement.location.tap do |location|
          if geo = @query.geo
            location.city = geo.locality
            location.state_code = geo.region
            location.country = geo.country
            location.country_code = geo.country_code
            location.latitude ||= geo.latitude
            location.longitude ||= geo.longitude
          else
            location.name = payload.fetch('location')
            location.city = payload.using(/^(.*?),/).fetch('location')
            location.state_code = payload.using(/,(.*?)$/).fetch('location')
            location.country_code = 'US'
          end
        end
      end
    end
  end
end
