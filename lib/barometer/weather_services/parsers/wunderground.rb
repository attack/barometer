module Barometer
  module Parser
    class Wunderground
      def initialize(measurement, query)
        @measurement = measurement
        @query = query
      end

      def parse_current(payload)
        _parse_current(payload)
        # _parse_sun(payload)
        _parse_station(payload)
        _parse_location(payload)
        _parse_time(payload)

        @measurement
      end

      def parse_forecast(payload)
        _build_forecasts(payload)

        @measurement
      end

      private

      # {"credit"=>"Weather Underground NOAA Weather Station",
      # "credit_URL"=>"http://wunderground.com/",

      # "pressure_mb"=>"1015",
      # "pressure_in"=>"29.98",
      # "visibility_mi"=>"20.0",
      # "visibility_km"=>"32.2",

      def _parse_current(payload)
        current = Measurement::Result.new

        current.humidity = payload.fetch('relative_humidity')
        current.condition = payload.fetch('weather')
        current.icon = payload.fetch('icon')
        current.temperature << [payload.fetch('temp_c'), payload.fetch('temp_f')]
        current.dew_point << [payload.fetch('dewpoint_c'), payload.fetch('dewpoint_f')]
        current.wind_chill << [payload.fetch('windchill_c'), payload.fetch('windchill_f')]
        current.heat_index << [payload.fetch('heat_index_c'), payload.fetch('heat_index_f')]
        current.wind.mph = payload.fetch('wind_mph').to_i
        current.wind.direction = payload.fetch('wind_dir')
        current.wind.degrees = payload.fetch('wind_degrees').to_i
        # current.pressure = payload.fetch('pressure')

        @measurement.current = current
      end

      # if data['observation_time'] && data['observation_time'].match(/\d/)
      #   current.updated_at = Data::LocalDateTime.parse(data['observation_time'])
      # end

      # current.pressure = Data::Pressure.new(metric)
      # current.pressure << [data['pressure_mb'], data['pressure_in']]
      # current.visibility = Data::Distance.new(metric)
      # current.visibility << [data['visibility_km'], data['visibility_mi']]


      # def _parse_sun(payload)
      #   rise_h = payload.fetch('sunrise', 'hour', '@hour_24').to_i
      #   rise_m = payload.fetch('sunrise', 'minute', '@number').to_i
      #   rise_s = payload.fetch('sunrise', 'second', '@number').to_i
      #   @measurement.current.sun.rise = Data::LocalTime.new(rise_h, rise_m, rise_s)

      #   set_h = payload.fetch('sunset', 'hour', '@hour_24').to_i
      #   set_m = payload.fetch('sunset', 'minute', '@number').to_i
      #   set_s = payload.fetch('sunset', 'second', '@number').to_i
      #   @measurement.current.sun.set = Data::LocalTime.new(set_h, set_m, set_s)
      # end

      def _parse_station(payload)
        station = Data::Location.new

        station.id = payload.fetch('station_id')
        station.name = payload.fetch('observation_location', 'full')
        station.city = payload.fetch('observation_location', 'city')
        station.state_code = payload.fetch('observation_location', 'state')
        station.country_code = payload.fetch('observation_location', 'country')
        station.latitude = payload.fetch('observation_location', 'latitude')
        station.longitude = payload.fetch('observation_location', 'longitude')

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
          location.name = payload.fetch('display_location', 'full')
          location.city = payload.fetch('display_location', 'city')
          location.state_code = payload.fetch('display_location', 'state')
          location.state_name = payload.fetch('display_location', 'state_name')
          location.zip_code = payload.fetch('display_location', 'zip')
          location.country_code = payload.fetch('display_location', 'country')
          location.latitude = payload.fetch('display_location', 'latitude')
          location.longitude = payload.fetch('display_location', 'longitude')
        end

        @measurement.location = location
      end

      # "observation_time"=>"Last Updated on February 9, 11:00 AM MST",
      # "observation_time_rfc822"=>"Sat, 09 Feb 2013 18:00:00 GMT",
      # "observation_epoch"=>"1360432800",
      # "local_time"=>"February 9, 11:43 AM MST",
      # "local_time_rfc822"=>"Sat, 09 Feb 2013 18:43:07 GMT",
      # "local_epoch"=>"1360435387",

      def _parse_time(payload)
        @measurement.measured_at = payload.using(/Last Updated on (.*)/).fetch('observation_time'), "%B %e, %l:%M %p %Z"
        # @measurement.measured_at = payload.fetch('observation_time_rfc822'), "%a, %d %b %Y %H:%M:%S %Z"
        @measurement.current.current_at = payload.fetch('local_time'), "%B %e, %l:%M %p %Z"
        # @measurement.current.current_at = payload.fetch('local_time_rfc822'), "%a, %d %b %Y %H:%M:%S %Z"
      end

      def _parse_zone(payload)
        @measurement.timezone = Data::Zone.new(payload.fetch('date', 'tz_long'))
      end

      def _build_forecasts(payload)
        forecasts = Measurement::ResultArray.new

        payload.fetch("simpleforecast", "forecastday").each do |forecast|
          forecast_payload = Barometer::Payload.new(forecast)
          forecasts << _build_single_forecast(forecast_payload)
        end

        @measurement.forecast = forecasts
      end

      def _build_single_forecast(payload)
        _parse_zone(payload)

        forecast_measurement = Measurement::Result.new

        forecast_measurement.icon = payload.fetch('icon')
        # forecast_measurement.date = payload.fetch('date', 'pretty'), "%h:%m %p on %B %d, %Y"
        forecast_measurement.pop = payload.fetch('pop').to_i
        forecast_measurement.high << [payload.fetch('high', 'celsius'), payload.fetch('high', 'fahrenheit')]
        forecast_measurement.low << [payload.fetch('low', 'celsius'), payload.fetch('low', 'fahrenheit')]

        forecast_measurement
      end
    end
  end
end

# def self._build_links(data)
#   links = {}
#   if data["credit"] && data["credit_URL"]
#     links[data["credit"]] = data["credit_URL"]
#   end
#   links
# end

# def self._build_sun(data)
#   raise ArgumentError unless data.is_a?(Hash)
#   sun = nil
#   if data
#     if data['moon_phase']
#       rise = Data::LocalTime.new(
#         data['moon_phase']['sunrise']['hour'].to_i,
#         data['moon_phase']['sunrise']['minute'].to_i
#       ) if data['moon_phase']['sunrise']
#       set = Data::LocalTime.new(
#         data['moon_phase']['sunset']['hour'].to_i,
#         data['moon_phase']['sunset']['minute'].to_i
#       ) if data['moon_phase']['sunset']
#       sun = Data::Sun.new(rise,set)
#     end
#   end
#   sun || Data::Sun.new
# end


# def self._links_result(data=nil); data[0]; end
# def self._sun_result(data=nil); data[1]; end
