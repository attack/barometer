module Barometer
  #
  # = Weather Underground
  # www.wunderground.com
  #
  # - key required: NO
  # - registration required: NO
  # - supported countries: ALL
  #
  # === performs geo coding
  # - city: YES
  # - coordinates: YES
  # NOTE: provides geo data for location and weather station
  #
  # === time info
  # - sun rise/set: YES (today only)
  # - provides timezone: YES
  # - requires TZInfo: YES
  # *NOTE: If accuarcy of times and converting, this service is the top choice.
  #        They provide the full timezone name that is needed for the most
  #        accurate time conversions.
  #
  # == resources
  # - API: http://wiki.wunderground.com/index.php/API_-_XML
  #
  # === Possible queries:
  # - http://api.wunderground.com/auto/wui/geo/GeoLookupXML/index.xml?query=94107
  # - http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=KSFO
  # - http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=KCASANFR70
  # - http://api.wunderground.com/auto/wui/geo/AlertsXML/index.xml?query=86445
  # - http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=Chicago,IL
  #
  # where query can be:
  # - zipcode (US or Canadian)
  # - city state; city, state
  # - city
  # - state
  # - country
  # - airport code (3-letter or 4-letter)
  # - lat,lon
  #
  # = Wunderground terms of use
  # Unable to locate.
  #
  class Wunderground < Service
    
    def self.accepted_formats
      [:zipcode, :postalcode, :icao, :coordinates, :geocode]
    end
    
    def self.source_name
      :wunderground
    end
    
    # these are the icon codes that indicate "wet", used by wet? function
    def self.wet_icon_codes
      %w(flurries rain sleet snow tstorms nt_flurries nt_rain nt_sleet nt_snow nt_tstorms chancerain)
    end
    # these are the icon codes that indicate "sun", used by sunny? function
    def self.sunny_icon_codes
      %w(clear mostlysunny partlysunny sunny partlycloudy)
    end

    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless query.is_a?(Barometer::Query)
      measurement.source = self.source_name
      
      
      # get current measurement
      begin
        current_result = self.get_current(query.preferred)
        measurement.current = self.build_current(current_result, metric)
      rescue Timeout::Error => e
        return measurement
      end
      
      # get forecast measurement
      begin
        forecast_result = self.get_forecast(query.preferred)
        measurement.forecast = self.build_forecast(forecast_result, metric)
      rescue Timeout::Error => e
        return measurement
      end
      
      measurement.location = self.build_location(current_result)
      measurement.station = self.build_station(current_result)
      measurement.timezone = self.build_timezone(forecast_result)
      
      # add links
      if current_result["credit"] && current_result["credit_URL"]
        measurement.links[current_result["credit"]] = current_result["credit_URL"]
      end
      
      # add sun data to current
      sun = nil
      if measurement.current
         sun = self.build_sun(forecast_result, measurement.timezone)
         measurement.current.sun = sun
      end
      # use todays sun data for all future days
      if measurement.forecast && sun
        measurement.forecast.each do |forecast|
          forecast.sun = sun
        end
      end
      
      # save the local time
      local_time = measurement.timezone ? Data::LocalTime.parse(
        measurement.timezone.utc_to_local(Time.now.utc)
      ) : nil
      measurement.measured_at = local_time
      measurement.current.current_at = local_time
      
      measurement
    end
    
    def self.build_current(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      
      current = Data::CurrentMeasurement.new
      current.updated_at = Data::LocalDateTime.parse(data['observation_time'])
      current.humidity = data['relative_humidity'].to_i
      current.icon = data['icon'] if data['icon']
      
      current.temperature = Data::Temperature.new(metric)
      current.temperature << [data['temp_c'], data['temp_f']]
      
      current.wind = Data::Speed.new(metric)
      current.wind.mph = data['wind_mph'].to_f
      current.wind.degrees = data['wind_degrees'].to_i
      current.wind.direction = data['wind_dir']
      
      current.pressure = Data::Pressure.new(metric)
      current.pressure << [data['pressure_mb'], data['pressure_in']]
      
      current.dew_point = Data::Temperature.new(metric)
      current.dew_point << [data['dewpoint_c'], data['dewpoint_f']]
      
      current.heat_index = Data::Temperature.new(metric)
      current.heat_index << [data['heat_index_c'], data['heat_index_f']]
      
      current.wind_chill = Data::Temperature.new(metric)
      current.wind_chill << [data['windchill_c'], data['windchill_f']]
      
      current.visibility = Data::Distance.new(metric)
      current.visibility << [data['visibility_km'], data['visibility_mi']]
      
      current
    end
    
    def self.build_forecast(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      forecasts = []
      # go through each forecast and create an instance
      if data && data['simpleforecast'] &&
         data['simpleforecast']['forecastday']
         
        data['simpleforecast']['forecastday'].each do |forecast|
          forecast_measurement = Data::ForecastMeasurement.new
          forecast_measurement.icon = forecast['icon']
          forecast_measurement.date = Date.parse(forecast['date']['pretty'])
          forecast_measurement.pop = forecast['pop'].to_i
          
          forecast_measurement.high = Data::Temperature.new(metric)
          forecast_measurement.high << [forecast['high']['celsius'],forecast['high']['fahrenheit']]
          
          forecast_measurement.low = Data::Temperature.new(metric)
          forecast_measurement.low << [forecast['low']['celsius'],forecast['low']['fahrenheit']]
          
          forecasts << forecast_measurement
        end
      end
      forecasts
    end

    def self.build_location(data)
      raise ArgumentError unless data.is_a?(Hash)
      location = Data::Location.new
      if data['display_location']
        location.name = data['display_location']['full']
        location.city = data['display_location']['city']
        location.state_name = data['display_location']['state_name']
        location.state_code = data['display_location']['state']
        location.country_code = data['display_location']['country']
        location.zip_code = data['display_location']['zip']
        location.latitude = data['display_location']['latitude']
        location.longitude = data['display_location']['longitude']
      end
      location
    end
    
    def self.build_station(data)
      raise ArgumentError unless data.is_a?(Hash)
      station = Data::Location.new
      station.id = data['station_id']
      if data['observation_location']
        station.name = data['observation_location']['full']
        station.city = data['observation_location']['city']
        station.state_name = data['observation_location']['state_name']
        station.state_code = data['observation_location']['state']
        station.country_code = data['observation_location']['country']
        station.zip_code = data['observation_location']['zip']
        station.latitude = data['observation_location']['latitude']
        station.longitude = data['observation_location']['longitude']
      end
      station
    end
    
    # <forecastday>
    #       <date>
    #         <pretty_short>9:00 PM CST</pretty_short>
    #         <pretty>9:00 PM CST on January 15, 2008</pretty>
    #         <isdst>0</isdst>
    #         <tz_short>CST</tz_short>
    #         <tz_long>America/Chicago</tz_long>
    #       </date>
    #     </forecastday>
    def self.build_timezone(data)
      raise ArgumentError unless data.is_a?(Hash)
      timezone = nil
      if data && data['simpleforecast'] &&
         data['simpleforecast']['forecastday'] &&
         data['simpleforecast']['forecastday'].first &&
         data['simpleforecast']['forecastday'].first['date']
        timezone = Data::Zone.new(
          data['simpleforecast']['forecastday'].first['date']['tz_long']
        )
      end
      timezone
    end
    
    def self.build_sun(data, timezone)
      raise ArgumentError unless data.is_a?(Hash)
      raise ArgumentError unless timezone.is_a?(Data::Zone)
      
      # sun = nil
      # if data
      #   time = nil
      #   if data['simpleforecast'] &&
      #      data['simpleforecast']['forecastday'] &&
      #      data['simpleforecast']['forecastday'].first &&
      #      data['simpleforecast']['forecastday'].first['date']
      #     
      #     # construct current date
      #     date_data = data['simpleforecast']['forecastday'].first['date']
      #     time = Time.local(
      #       date_data['year'], date_data['month'], date_data['day'],
      #       date_data['hour'], date_data['min'], date_data['sec']
      #     )
      #   end
      #   if time && data['moon_phase']
      #     # get the sun rise and set times (ie "6:32 am")
      #     if data['moon_phase']['sunrise']
      #       rise = Time.local(
      #         time.year, time.month, time.day,
      #         data['moon_phase']['sunrise']['hour'],
      #         data['moon_phase']['sunrise']['minute']
      #       )
      #     end
      #     if data['moon_phase']['sunset']
      #       set = Time.local(
      #         time.year, time.month, time.day,
      #         data['moon_phase']['sunset']['hour'],
      #         data['moon_phase']['sunset']['minute']
      #       )
      #     end
      #   
      #     sun = Data::Sun.new(
      #       timezone.tz.local_to_utc(rise),
      #       timezone.tz.local_to_utc(set)
      #     )
      #   end
      # end
      # 
      # sun || Data::Sun.new
      sun = nil
      if data
        if data['moon_phase']
          if data['moon_phase']['sunrise']
            rise = Data::LocalTime.new(
              data['moon_phase']['sunrise']['hour'].to_i,
              data['moon_phase']['sunrise']['minute'].to_i
            )
          end
          if data['moon_phase']['sunset']
            set = Data::LocalTime.new(
              data['moon_phase']['sunset']['hour'].to_i,
              data['moon_phase']['sunset']['minute'].to_i
            )
          end
        
          sun = Data::Sun.new(
            rise,
            set
          )
        end
      end
      sun || Data::Sun.new
    end
    
    # use HTTParty to get the current weather
    def self.get_current(query)
      Barometer::Wunderground.get(
       "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml",
       :query => {:query => query},
       :format => :xml,
       :timeout => Barometer.timeout
       )['current_observation']
    end
    
    # use HTTParty to get the forecasted weather
    def self.get_forecast(query)
      Barometer::Wunderground.get(
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml",
        :query => {:query => query},
        :format => :xml,
        :timeout => Barometer.timeout
      )['forecast']
    end
    
  end
end