module Barometer
  #
  # Weather Underground
  # www.wunderground.com
  #
  # key required: NO
  # registration required: NO
  # supported countries: ALL
  #
  # performs geo coding
  # city: YES
  # coordinates: YES
  # NOTE: provides geo data for location and weather station
  #
  # timezone info
  # provides zone: YES (but only in forecast query)
  #
  # API: http://wiki.wunderground.com/index.php/API_-_XML
  #
  # Possible queries:
  #  - http://api.wunderground.com/auto/wui/geo/GeoLookupXML/index.xml?query=94107
  #  - http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=KSFO
  #  - http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=KCASANFR70
  #  - http://api.wunderground.com/auto/wui/geo/AlertsXML/index.xml?query=86445
  #  - http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=Chicago,IL
  #
  # where query can be:
  #
  #    * zipcode (US or Canadian)
  #    * city state; city, state
  #    * city
  #    * state
  #    * country
  #    * airport code (3-letter or 4-letter)
  #    * lat,lon
  #
  class Wunderground < Service
    
    def self.accepted_formats
      [:zipcode, :postalcode, :coordinates, :geocode]
    end
    
    def self.source_name
      :wunderground
    end
    
    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless query.is_a?(String)
      measurement.source = self.source_name
      
      # get current measurement
      current_result = self.get_current(query)
      current_measurement = self.build_current(current_result, metric)
      measurement.success! if
        (current_measurement.temperature && !current_measurement.temperature.c.nil?)
      measurement.current = current_measurement
      
      # get forecast measurement
      forecast_result = self.get_forecast(query)
      forecast_measurements = self.build_forecast(forecast_result, metric)
      measurement.forecast = forecast_measurements
      
      # build extra data
      measurement.location = self.build_location(current_result)
      measurement.station = self.build_station(current_result)
      measurement.timezone = self.build_timezone(forecast_result)
      
      measurement
    end

    def self.build_current(current_result, metric=true)
      raise ArgumentError unless current_result.is_a?(Hash)
      
      current = CurrentMeasurement.new
      
      #current.time = Time.parse(current_result['observation_time_rfc822']) unless
      #  current_result['observation_time_rfc822'].blank?
      current.time = current_result['observation_time_rfc822']
      current.local_time = current_result['observation_time']
      current.humidity = current_result['relative_humidity'].to_i
      current.icon = current_result['icon'] if current_result['icon']

      temp = Temperature.new(metric)
      if metric
        temp.c = current_result['temp_c'].to_f
      else
        temp.f = current_result['temp_f'].to_f
      end
      current.temperature = temp

      wind = Speed.new(metric)
      wind.mph = current_result['wind_mph'].to_f
      wind.degrees = current_result['wind_degrees'].to_i
      wind.direction = current_result['wind_dir']
      current.wind = wind

      pressure = Pressure.new(metric)
      if metric
        pressure.mb = current_result['pressure_mb'].to_f
      else
        pressure.in = current_result['pressure_in'].to_f
      end
      current.pressure = pressure

      dew_point = Temperature.new(metric)
      if metric
        dew_point.c = current_result['dewpoint_c'].to_f
      else
        dew_point.f = current_result['dewpoint_f'].to_f
      end
      current.dew_point = dew_point

      heat_index = Temperature.new(metric)
      if metric
        heat_index.c = current_result['heat_index_c'].to_f
      else
        heat_index.f = current_result['heat_index_f'].to_f
      end
      current.heat_index = heat_index

      wind_chill = Temperature.new(metric)
      if metric
        wind_chill.c = current_result['windchill_c'].to_f
      else
        wind_chill.f = current_result['windchill_f'].to_f
      end
      current.wind_chill = wind_chill

      visibility = Distance.new(metric)
      if metric
        visibility.km = current_result['visibility_km'].to_f
      else
        visibility.m = current_result['visibility_mi'].to_f
      end
      current.visibility = visibility
      
      current
    end
    
    def self.build_forecast(forecast_result, metric=true)
      raise ArgumentError unless forecast_result.is_a?(Hash)
      
      forecasts = []

      # TODO sun/moon
      # - we are only given todays data for this, so create it here and
      # use the same values for the remaing forcasted days

      # go through each forecast and create an instance
      if forecast_result && forecast_result['simpleforecast'] &&
        forecast_result['simpleforecast']['forecastday']
        
        forecast_result['simpleforecast']['forecastday'].each do |forecast|
          forecast_measurement = ForecastMeasurement.new

          forecast_measurement.icon = forecast['icon']
          #forecast_measurement.icon2 = forecast['skyicon']

          forecast_measurement.date = Date.parse(forecast['date']['pretty'])

          high = Temperature.new(metric)
          if metric
            high.c = forecast['high']['celsius'].to_f
          else
            high.f = forecast['high']['fahrenheit'].to_f
          end
          forecast_measurement.high = high

          low = Temperature.new(metric)
          if metric
            low.c = forecast['low']['celsius'].to_f
          else
            low.f = forecast['low']['fahrenheit'].to_f
          end
          forecast_measurement.low = low

          forecasts << forecast_measurement
        end
      end
      
      forecasts
    end

    def self.build_location(location_result)
      raise ArgumentError unless location_result.is_a?(Hash)
      
      location = Location.new
      if location_result['display_location']
        location.name = location_result['display_location']['full']
        location.city = location_result['display_location']['city']
        location.state_name = location_result['display_location']['state_name']
        location.state_code = location_result['display_location']['state']
        location.country_code = location_result['display_location']['country']
        location.zip_code = location_result['display_location']['zip']
        location.latitude = location_result['display_location']['latitude']
        location.longitude = location_result['display_location']['longitude']
      end
      
      location
    end
    
    def self.build_station(station_result)
      raise ArgumentError unless station_result.is_a?(Hash)
      
      station = Location.new
      station.id = station_result['station_id']
      if station_result['observation_location']
        station.name = station_result['observation_location']['full']
        station.city = station_result['observation_location']['city']
        station.state_name = station_result['observation_location']['state_name']
        station.state_code = station_result['observation_location']['state']
        station.country_code = station_result['observation_location']['country']
        station.zip_code = station_result['observation_location']['zip']
        station.latitude = station_result['observation_location']['latitude']
        station.longitude = station_result['observation_location']['longitude']
      end
      
      station
    end
    
    # <forecastday>
    #       <date>
    #         <epoch>1200452404</epoch>
    #         <pretty_short>9:00 PM CST</pretty_short>
    #         <pretty>9:00 PM CST on January 15, 2008</pretty>
    #         <day>15</day>
    #         <month>1</month>
    #         <year>2008</year>
    #         <yday>14</yday>
    #         <hour>21</hour>
    #         <min>00</min>
    #         <sec>4</sec>
    #         <isdst>0</isdst>
    #         <monthname>January</monthname>
    #         <weekday_short/>
    #         <weekday>Tuesday</weekday>
    #         <ampm>PM</ampm>
    #         <tz_short>CST</tz_short>
    #         <tz_long>America/Chicago</tz_long>
    #       </date>
    #     </forecastday>
    def self.build_timezone(timezone_result)
      raise ArgumentError unless timezone_result.is_a?(Hash)
      
      timezone = nil
      if timezone_result && timezone_result['simpleforecast'] &&
         timezone_result['simpleforecast']['forecastday'] &&
         timezone_result['simpleforecast']['forecastday'].first &&
         timezone_result['simpleforecast']['forecastday'].first['date']
        timezone = Barometer::Zone.new(Time.now.utc,timezone_result['simpleforecast']['forecastday'].first['date']['tz_long'])
      end
      timezone
    end
    
    # use HTTParty to get the current weather
    def self.get_current(query)
      Barometer::Wunderground.get(
       "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml",
       :query => {:query => query},
       :format => :xml
       )['current_observation']
    end
    
    # use HTTParty to get the forecasted weather
    def self.get_forecast(query)
      Barometer::Wunderground.get(
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml",
        :query => {:query => query},
        :format => :xml
      )['forecast']
    end
    
  end
end