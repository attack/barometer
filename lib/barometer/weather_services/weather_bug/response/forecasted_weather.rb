module Barometer
  module WeatherService
    class WeatherBug
      class Response
        class ForecastedWeather
          def initialize(payload, timezone)
            @payload = payload
            @timezone = timezone
            @predictions = Barometer::Response::PredictionCollection.new
          end

          def parse
            each_prediction do |prediction, forecast_payload, index|
              prediction.date = date(index), timezone
              prediction.condition = condition(forecast_payload)
              prediction.icon = icon(forecast_payload)
              prediction.high = high(forecast_payload)
              prediction.low = low(forecast_payload)
            end

            predictions
          end

          private

          attr_reader :payload, :timezone, :predictions

          def units
            payload.units
          end

          def each_prediction
            payload.fetch_each_with_index('forecast') do |forecast_payload, index|
              predictions.build do |prediction|
                yield prediction, forecast_payload, index
              end
            end
          end

          def start_date
            Date.strptime(payload.fetch('@date'), '%m/%d/%Y %H:%M:%S %p')
          end

          def date(index)
            start_date + index
          end

          def condition(forecast_payload)
            forecast_payload.fetch('short_prediction')
          end

          def icon(forecast_payload)
            forecast_payload.using(/cond0*([1-9][0-9]*)\.gif$/).fetch('image')
          end

          def high(forecast_payload)
            [units, forecast_payload.fetch('high')]
          end

          def low(forecast_payload)
            [units, forecast_payload.fetch('low')]
          end
        end
      end
    end
  end
end
