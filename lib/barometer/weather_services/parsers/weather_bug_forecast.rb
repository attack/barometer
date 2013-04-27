module Barometer
  module Parser
    class WeatherBugForecast
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse(payload)
        _build_forecasts(payload)
        _parse_location(payload)

        @measurement
      end

      private

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
            location.city = payload.fetch('location', 'city')
            location.state_code = payload.fetch('location', 'state')
            location.zip_code = payload.fetch('location', 'zip')
          end
        end
      end

      def _build_forecasts(payload)
        start_date = Date.strptime(payload.fetch('@date'), "%m/%d/%Y %H:%M:%S %p")

        payload.fetch_each_with_index("forecast") do |forecast_payload, index|
          @measurement.build_forecast do |forecast_measurement|
            forecast_measurement.date = (start_date + index), @measurement.timezone

            forecast_measurement.icon = forecast_payload.using(/cond0*([1-9][0-9]*)\.gif$/).fetch('image')
            forecast_measurement.condition = forecast_payload.fetch('short_prediction')
            forecast_measurement.high = [forecast_payload.fetch('high')]
            forecast_measurement.low = [forecast_payload.fetch('low')]
          end
        end
      end
    end
  end
end
