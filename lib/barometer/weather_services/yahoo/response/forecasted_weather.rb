module Barometer
  module WeatherService
    class Yahoo
      class Response
        class ForecastedWeather
          def initialize(payload, timezone, current_sun)
            @payload = payload
            @timezone = timezone
            @current_sun = current_sun
            @predictions = Barometer::Response::PredictionCollection.new
          end

          def parse
            each_prediction do |prediction, forecast_payload|
              prediction.date = date(forecast_payload), timezone
              prediction.icon = icon(forecast_payload)
              prediction.condition = condition(forecast_payload)
              prediction.high = high(forecast_payload)
              prediction.low = low(forecast_payload)
              prediction.sun = sun(forecast_payload, prediction.starts_at, prediction.ends_at)
            end

            predictions
          end

          private

          attr_reader :payload, :timezone, :predictions, :current_sun

          def units
            payload.units
          end

          def each_prediction
            payload.fetch_each('item', 'forecast') do |forecast_payload|
              predictions.build do |prediction|
                yield prediction, forecast_payload
              end
            end
          end

          def date(forecast_payload)
            forecast_payload.fetch('@date')
          end

          def icon(forecast_payload)
            forecast_payload.fetch('@code')
          end

          def condition(forecast_payload)
            forecast_payload.fetch('@text')
          end

          def high(forecast_payload)
            [units, forecast_payload.fetch('@high')]
          end

          def low(forecast_payload)
            [units, forecast_payload.fetch('@low')]
          end

          def sun(forecast_payload, starts_at, ends_at)
            utc_rise_time = Utils::Time.utc_merge_base_plus_time(starts_at, current_sun.rise)
            utc_set_time = Utils::Time.utc_merge_base_plus_time(ends_at, current_sun.set)
            Data::Sun.new(utc_rise_time, utc_set_time)
          end
        end
      end
    end
  end
end
