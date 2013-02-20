module Barometer
  module Parser
    class Yahoo
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse_weather(payload)
        _parse_current(payload)
        _build_forecasts(payload)
        _parse_location(payload)
        _parse_time(payload)
        _parse_zone(payload)
        _parse_sun(payload)

        @measurement
      end

      private

      def _parse_current(payload)
        current = Measurement::Result.new

        current.condition = payload.fetch('item', 'condition', '@text')
        current.icon = payload.fetch('item', 'condition', '@code')
        current.temperature = payload.fetch('item', 'condition', '@temp')

        current.humidity = payload.fetch('atmosphere', '@humidity')
        current.pressure = payload.fetch('atmosphere', '@pressure')
        # current.visibility = payload.fetch('atmosphere', '@visibility')

        current.wind_chill = payload.fetch('wind', '@chill')
        current.wind.speed = payload.fetch('wind', '@speed')
        current.wind.degrees = payload.fetch('wind', '@direction')

        @measurement.current = current
      end

      def _parse_sun(payload)
        @measurement.current.sun.rise = Data::LocalTime.parse(payload.fetch("astronomy", "@sunrise"))
        @measurement.current.sun.set = Data::LocalTime.parse(payload.fetch("astronomy", "@sunset"))
      end

      def _parse_location(payload)
        location = Data::Location.new

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

        @measurement.location = location
      end

      def _parse_time(payload)
        @measurement.measured_at = payload.fetch('item', 'condition', '@date'), "%a, %d %b %Y %l:%M %P %Z"
        @measurement.current.current_at = payload.fetch('item', 'pubDate'), "%a, %d %b %Y %l:%M %P %Z"
      end

      def _parse_zone(payload)
        @measurement.timezone = Data::Zone.new(payload.using(/ ([A-Z]+)$/).fetch('item', 'pubDate'))
      end

      def _build_forecasts(payload)
        forecasts = Measurement::ResultArray.new

        payload.fetch("item", "forecast").each do |forecast|
          forecast_payload = Barometer::Payload.new(forecast)
          forecasts << _build_single_forecast(forecast_payload)
        end

        @measurement.forecast = forecasts
      end

      def _build_single_forecast(payload)
        forecast_measurement = Measurement::Result.new

        forecast_measurement.date = Date.parse(payload.fetch('@date'))
        forecast_measurement.icon = payload.fetch('@code')
        forecast_measurement.condition = payload.fetch('@text')
        forecast_measurement.high = payload.fetch('@high')
        forecast_measurement.low = payload.fetch('@low')

        forecast_measurement
      end
    end
  end
end
