module Barometer
  module Parser
    class Yahoo
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse_weather(payload)
        _parse_time(payload)
        _parse_current(payload)
        _build_forecasts(payload)
        _parse_location(payload)
        _parse_sun(payload)

        @measurement
      end

      private

      def _parse_current(payload)
        @measurement.current.tap do |current|
          current.starts_at = payload.fetch('item', 'pubDate'), "%a, %d %b %Y %l:%M %P %Z"

          current.condition = payload.fetch('item', 'condition', '@text')
          current.icon = payload.fetch('item', 'condition', '@code')
          current.temperature = payload.fetch('item', 'condition', '@temp')

          current.humidity = payload.fetch('atmosphere', '@humidity')
          current.pressure = payload.fetch('atmosphere', '@pressure')
          current.visibility = [payload.fetch('atmosphere', '@visibility')]

          current.wind_chill = payload.fetch('wind', '@chill')
          current.wind = [payload.fetch('wind', '@speed'), payload.fetch('wind', '@direction').to_f]
        end
      end

      def _parse_sun(payload)
        @measurement.current.sun.rise = Data::LocalTime.parse(payload.fetch("astronomy", "@sunrise"))
        @measurement.current.sun.set = Data::LocalTime.parse(payload.fetch("astronomy", "@sunset"))
      end

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
            location.city = payload.fetch('location', '@city')
            location.state_code = payload.fetch('location', '@region')
            location.country_code = payload.fetch('location', '@country')
            location.latitude = payload.fetch('item', 'lat')
            location.longitude = payload.fetch('item', 'long')
          end
        end
      end

      def _parse_time(payload)
        @measurement.timezone = payload.using(/ ([A-Z]+)$/).fetch('item', 'pubDate')
        @measurement.published_at = payload.fetch('item', 'pubDate'), "%a, %d %b %Y %l:%M %P %Z"
      end

      def _build_forecasts(payload)
        payload.fetch_each("item", "forecast") do |forecast_payload|
          @measurement.build_forecast do |forecast_measurement|
            forecast_measurement.date = Date.parse(forecast_payload.fetch('@date'))
            forecast_measurement.icon = forecast_payload.fetch('@code')
            forecast_measurement.condition = forecast_payload.fetch('@text')
            forecast_measurement.high = forecast_payload.fetch('@high')
            forecast_measurement.low = forecast_payload.fetch('@low')
            forecast_measurement.sun = @measurement.current.sun
          end
        end
      end
    end
  end
end
