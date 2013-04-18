module Barometer
  module Parser
    class Noaa
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse_current(payload)
        _parse_current(payload)
        _parse_station(payload)
        _parse_time(payload)
        _parse_location(payload)

        @measurement
      end

      def parse_forecast(payload)
        _build_forecasts(payload)
        _parse_forecast_location(payload)

        @measurement
      end

      private

      def _parse_current(payload)
        @measurement.current.tap do |current|
          current.starts_at = payload.fetch('observation_time_rfc822'), '%a, %d %b %Y %H:%M:%S %z'
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

      def _parse_forecast_location(payload)
        @measurement.location.tap do |location|
          location.latitude = payload.fetch('location', 'point', '@latitude')
          location.longitude = payload.fetch('location', 'point', '@longitude')
        end

        @measurement.station.tap do |station|
          station.latitude = payload.fetch('location', 'point', '@latitude')
          station.longitude = payload.fetch('location', 'point', '@longitude')
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

      def _parse_time(payload)
        @measurement.timezone = payload.using(/ ([A-Z]*)$/).fetch('observation_time')
        @measurement.published_at = payload.fetch('observation_time_rfc822'), '%a, %d %b %Y %H:%M:%S %z'
      end

      def _build_forecasts(payload)
        forecasts = Measurement::ResultArray.new

        p12h_start_times = payload.fetch('time_layout').detect{|layout| layout["layout_key"] == "k-p12h-n14-2"}["start_valid_time"]
        p12h_end_times = payload.fetch('time_layout').detect{|layout| layout["layout_key"] == "k-p12h-n14-2"}["end_valid_time"]

        high_temps = payload.fetch('parameters', 'temperature').detect{|t| t['@type'] == 'maximum'}.fetch('value', []).map(&:to_i)
        low_temps = payload.fetch('parameters', 'temperature').detect{|t| t['@type'] == 'minimum'}.fetch('value', []).map(&:to_i)
        pops = payload.fetch('parameters', 'probability_of_precipitation', 'value').map(&:to_i)
        summaries = payload.fetch('parameters', 'weather', 'weather_conditions').map{|c| c['@weather_summary'] }
        icons = payload.fetch('parameters', 'conditions_icon', 'icon_link').map{|l| l.match(/(\w*)\.[a-zA-Z]{3}$/)[1] }

        high_temps.each_with_index do |high_temp, index|
          @measurement.build_forecast do |forecast_measurement|
            forecast_measurement.pop = pops[index*2]
            forecast_measurement.high = [:imperial, high_temp]
            forecast_measurement.low = [:imperial, low_temps[index]]
            forecast_measurement.condition = summaries[index]
            forecast_measurement.icon = icons[index]
            forecast_measurement.starts_at = p12h_start_times[index*2]
            forecast_measurement.ends_at = p12h_end_times[index*2]
          end

          @measurement.build_forecast do |forecast_measurement|
            forecast_measurement.pop = pops[index*2 + 1]
            forecast_measurement.high = [:imperial, high_temp]
            forecast_measurement.low = [:imperial, low_temps[index]]
            forecast_measurement.condition = summaries[index]
            forecast_measurement.icon = icons[index]
            forecast_measurement.starts_at = p12h_start_times[index*2 + 1]
            forecast_measurement.ends_at = p12h_end_times[index*2 + 1]
          end
        end
      end
    end
  end
end
