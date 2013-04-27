module Barometer
  module Parser
    class WeatherBugForecast
      def initialize(response, query)
        @response = response
        @query = query
      end

      def parse(payload)
        _build_forecasts(payload)
        _parse_location(payload)

        @response
      end

      private

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
            location.city = payload.fetch('location', 'city')
            location.state_code = payload.fetch('location', 'state')
            location.zip_code = payload.fetch('location', 'zip')
          end
        end
      end

      def _build_forecasts(payload)
        start_date = Date.strptime(payload.fetch('@date'), "%m/%d/%Y %H:%M:%S %p")

        payload.fetch_each_with_index("forecast") do |forecast_payload, index|
          @response.build_forecast do |forecast_response|
            forecast_response.date = (start_date + index), @response.timezone

            forecast_response.icon = forecast_payload.using(/cond0*([1-9][0-9]*)\.gif$/).fetch('image')
            forecast_response.condition = forecast_payload.fetch('short_prediction')
            forecast_response.high = [forecast_payload.fetch('high')]
            forecast_response.low = [forecast_payload.fetch('low')]
          end
        end
      end
    end
  end
end
