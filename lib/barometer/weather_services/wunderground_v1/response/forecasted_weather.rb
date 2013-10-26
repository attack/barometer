module Barometer
  module WeatherService
    class WundergroundV1
      class Response
        class ForecastedWeather
          def initialize(payload, response)
            @payload = payload
            @response = response
            @predictions = Barometer::Response::PredictionCollection.new
          end

          def parse
            each_prediction do |prediction, forecast_payload|
              prediction.starts_at = starts_at(forecast_payload), '%I:%M %p %Z on %B %d, %Y'
              prediction.ends_at = ends_at(prediction.starts_at)
              prediction.pop = pop(forecast_payload)
              prediction.icon = icon(forecast_payload)
              prediction.high = high(forecast_payload)
              prediction.low = low(forecast_payload)
              prediction.sun = sun(prediction.starts_at, prediction.ends_at)
            end

            predictions
          end

          private

          attr_reader :payload, :response, :predictions

          def units
            payload.units
          end

          def each_prediction
            payload.fetch_each('simpleforecast', 'forecastday') do |forecast_payload|
              predictions.build do |prediction|
                yield prediction, forecast_payload
              end
            end
          end

          def starts_at(forecast_payload)
            forecast_payload.fetch('date', 'pretty')
          end

          def ends_at(starts_at)
            Utils::Time.add_one_day(starts_at)
          end

          def pop(forecast_payload)
            forecast_payload.fetch('pop')
          end

          def icon(forecast_payload)
            forecast_payload.fetch('icon')
          end

          def high(forecast_payload)
            [units, forecast_payload.fetch('high', 'celsius'), forecast_payload.fetch('high', 'fahrenheit')]
          end

          def low(forecast_payload)
            [units, forecast_payload.fetch('low', 'celsius'), forecast_payload.fetch('low', 'fahrenheit')]
          end

          def sun(starts_at, ends_at)
            Data::Sun.new(rise: sun_rise_utc(starts_at), set: sun_set_utc(ends_at))
          end

          def sun_rise_utc(starts_at)
            return unless current_sun?
            Utils::Time.utc_merge_base_plus_time(starts_at, response.current.sun.rise)
          end

          def sun_set_utc(ends_at)
            return unless current_sun?
            Utils::Time.utc_merge_base_plus_time(ends_at, response.current.sun.set)
          end

          def current_sun?
            response.current && response.current.sun
          end
        end
      end
    end
  end
end
