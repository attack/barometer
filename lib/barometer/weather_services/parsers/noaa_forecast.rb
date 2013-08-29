module Barometer
  module Parser
    class NoaaForecast
      def initialize(response)
        @response = response
      end

      def parse(payload)
        @payload = payload

        build_forecasts
        parse_location

        @response
      end

      private

      attr_reader :payload

      def build_forecasts
        each_forecast do |index, shared_index|
          @response.build_forecast do |forecast_response|
            forecast_response.starts_at = start_times[index]
            forecast_response.ends_at = end_times[index]
            forecast_response.icon = icons[shared_index]
            forecast_response.condition = summaries[shared_index]
            forecast_response.pop = precipitations[index]
            forecast_response.high = [:imperial, high_temperatures[shared_index]]
            forecast_response.low = [:imperial, low_temperatures[shared_index]]
          end
        end
      end

      def parse_location
        parse_forecast_location
        parse_forecast_station
      end

      def parse_forecast_location
        @response.location.tap do |location|
          location.latitude = latitude
          location.longitude = longitude
        end
      end

      def parse_forecast_station
        @response.station.tap do |station|
          station.latitude = latitude
          station.longitude = longitude
        end
      end

      def latitude
        @latitude ||= payload.fetch('location', 'point', '@latitude')
      end

      def longitude
        @longitude ||= payload.fetch('location', 'point', '@longitude')
      end

      def total_forecasts
        high_temperatures.count * 2
      end

      def each_forecast
        (0...total_forecasts).each do |index|
          yield index, shared_index(index)
        end
      end

      def shared_index(index)
        (index / 2).floor
      end

      def start_times
        @start_times ||= payload.fetch('time_layout').detect{|layout| layout['layout_key'] == 'k-p12h-n14-2'}['start_valid_time']
      end

      def end_times
        @end_times ||= payload.fetch('time_layout').detect{|layout| layout['layout_key'] == 'k-p12h-n14-2'}['end_valid_time']
      end

      def high_temperatures
        @high_temperatures ||= payload.fetch('parameters', 'temperature').detect{|t| t['@type'] == 'maximum'}.fetch('value', []).map(&:to_i)
      end

      def low_temperatures
        @low_temperatures ||= payload.fetch('parameters', 'temperature').detect{|t| t['@type'] == 'minimum'}.fetch('value', []).map(&:to_i)
      end

      def precipitations
        @precipitations ||= payload.fetch('parameters', 'probability_of_precipitation', 'value').map(&:to_i)
      end

      def summaries
        @summaries ||= payload.fetch('parameters', 'weather', 'weather_conditions').map{|c| c['@weather_summary'] }
      end

      def icons
        @icons ||= payload.fetch('parameters', 'conditions_icon', 'icon_link').map{|l| l.match(/(\w*)\.[a-zA-Z]{3}$/)[1] }
      end
    end
  end
end
