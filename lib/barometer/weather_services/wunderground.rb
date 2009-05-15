module Barometer
  #
  #   [DEFAULT PROVIDER]
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
  class WeatherService::Wunderground < WeatherService
    
    #########################################################################
    # PRIVATE
    # If class methods could be private, the remaining methods would be.
    #
    
    def self._source_name; :wunderground; end
    def self._accepted_formats
      [:zipcode, :postalcode, :icao, :coordinates, :geocode]
    end
    
    # these are the icon codes that indicate "wet", used by wet? function
    def self._wet_icon_codes
      %w(flurries rain sleet snow tstorms nt_flurries nt_rain nt_sleet nt_snow nt_tstorms chancerain chancetstorms)
    end
    # these are the icon codes that indicate "sun", used by sunny? function
    def self._sunny_icon_codes
      %w(clear mostlysunny partlysunny sunny partlycloudy)
    end

    def self._build_extra(measurement, result, metric=true)
      #raise ArgumentError unless measurement.is_a?(Data::Measurement)
      #raise ArgumentError unless query.is_a?(Barometer::Query)

      # use todays sun data for all future days
      if measurement.forecast && measurement.current.sun
        measurement.forecast.each do |forecast|
          forecast.sun = measurement.current.sun
        end
      end
      
      measurement
    end

    def self._parse_full_timezone(data)
      raise ArgumentError unless data.is_a?(Hash)
      if data && data['simpleforecast'] &&
         data['simpleforecast']['forecastday'] &&
         data['simpleforecast']['forecastday'].first &&
         data['simpleforecast']['forecastday'].first['date']
        Data::Zone.new(
          data['simpleforecast']['forecastday'].first['date']['tz_long']
        )
      end
    end
    
    def self._build_links(data)
      links = {}
      if data["credit"] && data["credit_URL"]
        links[data["credit"]] = data["credit_URL"]
      end
      links
    end

    def self._build_current(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      
      current = Measurement::Current.new
      current.updated_at = Data::LocalDateTime.parse(data['observation_time']) if data['observation_time']
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
    
    def self._build_forecast(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      forecasts = Measurement::ForecastArray.new
      # go through each forecast and create an instance
      if data && data['simpleforecast'] &&
         data['simpleforecast']['forecastday']
         
        data['simpleforecast']['forecastday'].each do |forecast|
          forecast_measurement = Measurement::Forecast.new
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
    
    def self._build_location(data, geo=nil)
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
    
    def self._build_station(data)
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
    
    def self._build_sun(data)
      raise ArgumentError unless data.is_a?(Hash)
      sun = nil
      if data
        if data['moon_phase']
          rise = Data::LocalTime.new(
            data['moon_phase']['sunrise']['hour'].to_i,
            data['moon_phase']['sunrise']['minute'].to_i
          ) if data['moon_phase']['sunrise']
          set = Data::LocalTime.new(
            data['moon_phase']['sunset']['hour'].to_i,
            data['moon_phase']['sunset']['minute'].to_i
          ) if data['moon_phase']['sunset']
          sun = Data::Sun.new(rise,set)
        end
      end
      sun || Data::Sun.new
    end
    
    # override default _fetch behavior
    # this service requires TWO seperate http requests (one for current
    # and one for forecasted weather) ... combine the results
    #
    def self._fetch(query, metric=true)
      result = []
      result << _fetch_current(query)
      result << _fetch_forecast(query)
      result
    end
    
    # use HTTParty to get the current weather
    #
    def self._fetch_current(query)
      puts "fetch wunderground current: #{query}" if Barometer::debug?
      return unless query
      self.get(
       "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml",
       :query => {:query => query},
       :format => :xml,
       :timeout => Barometer.timeout
       )['current_observation']
    end
    
    # use HTTParty to get the forecasted weather
    #
    def self._fetch_forecast(query)
      puts "fetch wunderground forecast: #{query}" if Barometer::debug?
      return unless query
      self.get(
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml",
        :query => {:query => query},
        :format => :xml,
        :timeout => Barometer.timeout
      )['forecast']
    end
    
    # since we have two sets of data, override these calls to choose the
    # right set of data
    #
    def self._current_result(data); data[0]; end
    def self._forecast_result(data=nil); data[1]; end
    def self._location_result(data=nil); data[0]; end
    def self._station_result(data=nil); data[0]; end
    def self._links_result(data=nil); data[0]; end
    def self._sun_result(data=nil); data[1]; end
    def self._timezone_result(data=nil); data[1]; end
    
  end
end