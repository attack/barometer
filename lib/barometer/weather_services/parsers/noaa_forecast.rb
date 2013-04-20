module Barometer
  module Parser
    class NoaaForecast
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse(payload)
        _build_forecasts(payload)
        _parse_forecast_location(payload)

        @measurement
      end

      private

      def _parse_forecast_location(payload)
        latitude = payload.fetch('location', 'point', '@latitude')
        longitude = payload.fetch('location', 'point', '@longitude')

        @query.add_conversion(:coordinates, "#{latitude},#{longitude}")

        @measurement.location.tap do |location|
          location.latitude = latitude
          location.longitude = longitude
        end

        @measurement.station.tap do |station|
          station.latitude = latitude
          station.longitude = longitude
        end
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
