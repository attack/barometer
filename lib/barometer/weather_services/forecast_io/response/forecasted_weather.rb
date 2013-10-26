module Barometer
  module WeatherService
    class ForecastIo
      class Response
        class ForecastedWeather
          def initialize(payload)
            @payload = payload
            @predictions = Barometer::Response::PredictionCollection.new
          end

          def parse
            each_prediction do |prediction, forecast_payload|
              prediction.starts_at = starts_at(forecast_payload)
              prediction.ends_at = Utils::Time.add_one_day(prediction.starts_at)
              prediction.icon = icon(forecast_payload)
              prediction.condition = condition(forecast_payload)
              prediction.high = high(forecast_payload)
              prediction.low = low(forecast_payload)
              prediction.sun = sun(forecast_payload, prediction.starts_at, prediction.ends_at)
            end

            predictions
          end

          private

          attr_reader :payload, :predictions

          def units
            payload.units
          end

          def each_prediction
            payload.fetch_each('daily', 'data') do |forecast_payload|
              predictions.build do |prediction|
                yield prediction, forecast_payload
              end
            end
          end

          def starts_at(forecast_payload)
            time(forecast_payload.fetch('time'))
          end

          def icon(forecast_payload)
            forecast_payload.fetch('icon')
          end

          def condition(forecast_payload)
            forecast_payload.fetch('summary')
          end

          def high(forecast_payload)
            [units, forecast_payload.fetch('temperatureMax')]
          end

          def low(forecast_payload)
            [units, forecast_payload.fetch('temperatureMin')]
          end

          def sun(forecast_payload, starts_at, ends_at)
            utc_rise_time = time(forecast_payload.fetch('sunriseTime'))
            utc_set_time = time(forecast_payload.fetch('sunsetTime'))
            Data::Sun.new(rise: utc_rise_time, set: utc_set_time)
          end

          def time(timestamp)
            Time.at(timestamp.to_i)
          end
        end
      end
    end
  end
end
