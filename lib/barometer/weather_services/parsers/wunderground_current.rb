module Barometer
  module Parser
    class WundergroundCurrent
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse(payload)
        _parse_current(payload)
        _parse_station(payload)
        _parse_location(payload)
        _parse_time(payload)

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
    end
  end
end
