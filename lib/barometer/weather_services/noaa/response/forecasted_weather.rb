module Barometer
  module WeatherService
    class Noaa
      class Response
        class ForecastedWeather
          def initialize(payload)
            @payload = payload
            @predictions = Barometer::Response::PredictionCollection.new
          end

          def parse
            each_prediction do |prediction, index, shared_index|
              prediction.starts_at = start_times[index]
              prediction.ends_at = end_times[index]
              prediction.icon = icons[shared_index]
              prediction.condition = summaries[shared_index]
              prediction.pop = precipitations[index]
              prediction.high = [:imperial, high_temperatures[shared_index]]
              prediction.low = [:imperial, low_temperatures[shared_index]]
            end

            predictions
          end

          private

          attr_reader :payload, :predictions

          def total_forecasts
            high_temperatures.count * 2
          end

          def each_forecast
            (0...total_forecasts).each do |index|
              yield index, shared_index(index)
            end
          end

          def each_prediction
            each_forecast do |index, shared_index|
              predictions.build do |prediction|
                yield prediction, index, shared_index
              end
            end
          end

          def shared_index(index)
            (index / 2).floor
          end

          def times
            @times ||= payload.fetch('time_layout').detect{|layout| layout['layout_key'] == 'k-p12h-n14-2'}
          end

          def start_times
            @start_times ||= times['start_valid_time']
          end

          def end_times
            @end_times ||= times['end_valid_time']
          end

          def temperatures
            @temperatures ||= payload.fetch('parameters', 'temperature')
          end

          def high_temperatures
            @high_temperatures ||= temperatures.detect{|t| t['@type'] == 'maximum'}.fetch('value', [])
          end

          def low_temperatures
            @low_temperatures ||= temperatures.detect{|t| t['@type'] == 'minimum'}.fetch('value', [])
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
  end
end
