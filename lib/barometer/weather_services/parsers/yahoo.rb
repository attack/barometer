module Barometer
  module Parser
    class Yahoo
      def initialize(response, query)
        @response = response
        @query = query
      end

      def parse(payload)
        _parse_time(payload)
        _parse_current(payload)
        _parse_sun(payload)
        _build_forecasts(payload)
        _parse_location(payload)

        @response
      end

      private

      def _parse_current(payload)
        @response.current.tap do |current|
          current.observed_at = payload.fetch('item', 'pubDate'), "%a, %d %b %Y %l:%M %P %Z"
          current.stale_at = (current.observed_at + (60 * 60 * 1)) if current.observed_at

          current.condition = payload.fetch('item', 'condition', '@text')
          current.icon = payload.fetch('item', 'condition', '@code')
          current.temperature = payload.fetch('item', 'condition', '@temp')

          current.humidity = payload.fetch('atmosphere', '@humidity')
          current.pressure = [payload.fetch('atmosphere', '@pressure')]
          current.visibility = [payload.fetch('atmosphere', '@visibility')]

          current.wind_chill = payload.fetch('wind', '@chill')
          current.wind = [payload.fetch('wind', '@speed'), payload.fetch('wind', '@direction').to_f]
        end
      end

      def _parse_sun(payload)
        rise_local = Barometer::Utils::Time.parse(payload.fetch("astronomy", "@sunrise"))
        set_local = Barometer::Utils::Time.parse(payload.fetch("astronomy", "@sunset"))
        return if rise_local.nil? || set_local.nil?

        rise_utc = Barometer::Utils::Time.utc_from_base_plus_local_time(
          @response.timezone, @response.current.observed_at, rise_local.hour, rise_local.min
        )
        set_utc = Barometer::Utils::Time.utc_from_base_plus_local_time(
          @response.timezone, @response.current.observed_at, set_local.hour, set_local.min
        )

        @response.current.sun = Data::Sun.new(rise_utc, set_utc)
      end

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
            location.city = payload.fetch('location', '@city')
            location.state_code = payload.fetch('location', '@region')
            location.country_code = payload.fetch('location', '@country')
            location.latitude = payload.fetch('item', 'lat')
            location.longitude = payload.fetch('item', 'long')
          end
        end
      end

      def _parse_time(payload)
        @response.timezone = payload.using(/ ([A-Z]+)$/).fetch('item', 'pubDate')
      end

      def _build_forecasts(payload)
        payload.fetch_each("item", "forecast") do |forecast_payload|
          @response.build_forecast do |forecast_response|
            forecast_response.date = forecast_payload.fetch('@date'), @response.timezone
            forecast_response.icon = forecast_payload.fetch('@code')
            forecast_response.condition = forecast_payload.fetch('@text')
            forecast_response.high = forecast_payload.fetch('@high')
            forecast_response.low = forecast_payload.fetch('@low')

            rise_utc = Barometer::Utils::Time.utc_merge_base_plus_time(
              forecast_response.starts_at, @response.current.sun.rise
            )
            set_utc = Barometer::Utils::Time.utc_merge_base_plus_time(
              forecast_response.ends_at, @response.current.sun.set
            )
            forecast_response.sun = Data::Sun.new(rise_utc, set_utc)
          end
        end
      end
    end
  end
end
