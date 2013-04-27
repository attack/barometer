module Barometer
  module Parser
    class WundergroundCurrent
      def initialize(response, query)
        @response = response
        @query = query
      end

      def parse(payload)
        _parse_current(payload)
        _parse_station(payload)
        _parse_location(payload)
        _parse_time(payload)

        @response
      end

      private

      def _parse_current(payload)
        @response.current.tap do |current|
          current.observed_at = payload.fetch('local_time'), "%B %e, %l:%M %p %Z"
          _parse_stale_at

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
        @response.station.tap do |station|
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
        @response.location.tap do |location|
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
        @response.timezone = payload.using(/ (\w*)$/).fetch('local_time')
      end

      # Wunderground syas they update their data on the hour, every hour
      def _parse_stale_at
        if @response.current.observed_at
          utc_observed_at = @response.current.observed_at.utc
          utc_next_update = Time.utc(
            utc_observed_at.year, utc_observed_at.month, utc_observed_at.day,
            utc_observed_at.hour + 1, 0, 0
          )
          @response.current.stale_at = utc_next_update
        end
      end
    end
  end
end
