module Barometer
  module Parser
    class WeatherBug
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse_current(payload)
        _parse_current(payload)
        _parse_sun(payload)
        _parse_station(payload)
        _parse_time(payload)
        _parse_zone(payload)

        @measurement
      end

      def parse_forecast(payload)
        _build_forecasts(payload)
        _parse_location(payload)

        @measurement
      end

      private

      def _parse_current(payload)
        current = Measurement::Result.new

        current.humidity = payload.fetch('humidity')
        current.condition = payload.fetch('current_condition')
        current.icon = payload.fetch('barometer:icon')
        current.temperature = payload.fetch('temp')
        current.dew_point = payload.fetch('dew_point')
        current.wind_chill = payload.fetch('feels_like')
        current.wind.speed = payload.fetch('wind_speed')
        current.wind.direction = payload.fetch('wind_direction')
        current.wind.degrees = payload.fetch('wind_direction_degrees')
        current.pressure = payload.fetch('pressure')

        @measurement.current = current
      end

      def _parse_sun(payload)
        rise_h = payload.fetch('sunrise', 'hour', '@hour_24').to_i
        rise_m = payload.fetch('sunrise', 'minute', '@number').to_i
        rise_s = payload.fetch('sunrise', 'second', '@number').to_i
        @measurement.current.sun.rise = Data::LocalTime.new(rise_h, rise_m, rise_s)

        set_h = payload.fetch('sunset', 'hour', '@hour_24').to_i
        set_m = payload.fetch('sunset', 'minute', '@number').to_i
        set_s = payload.fetch('sunset', 'second', '@number').to_i
        @measurement.current.sun.set = Data::LocalTime.new(set_h, set_m, set_s)
      end

      def _parse_station(payload)
        station = Data::Location.new

        station.id = payload.fetch('station_id')
        station.name = payload.fetch('station')
        station.city = payload.using(/^([\w ]*?),/).fetch('city_state')
        station.state_code = payload.using(/^[\w ^,]*?,([\w ^,]*)/).fetch('city_state')
        station.country = payload.fetch('country')
        station.zip_code = payload.fetch('barometer:station_zipcode')
        station.latitude = payload.fetch('latitude')
        station.longitude = payload.fetch('longitude')

        @measurement.station = station
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
          location.city = payload.fetch('location', 'city')
          location.state_code = payload.fetch('location', 'state')
          location.zip_code = payload.fetch('location', 'zip')
        end

        @measurement.location = location
      end

      def _parse_time(payload)
        datetime = [
          payload.fetch('ob_date', 'year', '@number').to_i,
          payload.fetch('ob_date', 'month', '@number').to_i,
          payload.fetch('ob_date', 'day', '@number').to_i,
          payload.fetch('ob_date', 'hour', '@hour_24').to_i,
          payload.fetch('ob_date', 'minute', '@number').to_i,
          payload.fetch('ob_date', 'second', '@number').to_i
        ]
        @measurement.measured_at = datetime
        @measurement.current.current_at = datetime
      end

      def _parse_zone(payload)
        @measurement.timezone = Data::Zone.new(payload.fetch('ob_date', 'time_zone', '@abbrv'))
      end

      def _build_forecasts(payload)
        forecasts = Measurement::ResultArray.new

        start_date = Date.strptime(payload.fetch('@date'), "%m/%d/%Y %H:%M:%S %p")
        payload.fetch("forecast").each_with_index do |forecast, index|
          forecast_payload = Barometer::Payload.new(forecast)
          forecasts << _build_single_forecast(forecast_payload, start_date, index)
        end

        @measurement.forecast = forecasts
      end

      def _build_single_forecast(payload, start_date, index)
        forecast_measurement = Measurement::Result.new

        forecast_measurement.icon = payload.using(/cond0*([1-9][0-9]*)\.gif$/).fetch('image')
        forecast_measurement.date = start_date + index
        forecast_measurement.condition = payload.fetch('short_prediction')
        forecast_measurement.high = payload.fetch('high')
        forecast_measurement.low = payload.fetch('low')

        forecast_measurement
      end
    end
  end
end
