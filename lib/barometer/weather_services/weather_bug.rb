module Barometer
  #
  # = WeatherBug
  # www.weatherbug.com
  #
  # - key required: YES (api_code)
  # - registration required: YES
  # - supported countries: US (by zipcode), International (by coordinates)
  #
  # === performs geo coding
  # - city: YES
  # - coordinates: PARTIAL (just for weather station)
  #
  # === time info
  # - sun rise/set: YES
  # - provides timezone: NO, but provides a timezone short code and utc offset
  # - requires TZInfo: NO
  #
  # == resources
  # - API: http://weather.weatherbug.com/corporate/products/API/help.aspx
  #
  # === Possible queries:
  # - http://[API_Code].api.wxbug.net:80/getLiveWeatherRSS.aspx?ACode=[API_Code]&OutputType=1&UnitType=1&zipCode=90210
  #
  # where query can be:
  # - zipcode (US) [5 digits only]
  # - coordinates (International)
  #
  # = WeatherBug.com terms of use
  # ???
  #
  # == notes
  # - WeatherBug also supports queries using "citycode" and "stationID", but these
  #   are specific to WeatherBug and un-supported by Barometer
  #
  class WeatherService::WeatherBug < WeatherService
    
    @@api_code = nil

    def self.keys=(keys)
      raise ArgumentError unless keys.is_a?(Hash)
      keys.each do |key, value|
        @@api_code = value.to_s if key.to_s.downcase == "code"
      end
    end

    #########################################################################
    # PRIVATE
    # If class methods could be private, the remaining methods would be.
    #

    def self._source_name; :weather_bug; end
    def self._accepted_formats; [:short_zipcode, :coordinates]; end

    def self._has_keys?; !@@api_code.nil?; end
    def self._requires_keys?; true; end

    def self._wet_icon_codes
      codes = [5,6,8,9,11,12,14,15] + (18..22).to_a + [25] + (27..30).to_a +
              [32,36] + (38..49).to_a + (52..63).to_a + (80..157).to_a +
              (161..176).to_a
      codes.collect {|c| c.to_s}
    end
    def self._sunny_icon_codes
      codes = [0,2,3,4,7,26,31,64,65,75]
      codes.collect {|c| c.to_s}
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

    def self._parse_local_time(data)
      Data::LocalTime.new(
        data["aws:ob_date"]["aws:hour"]["hour_24"].to_i,
        data["aws:ob_date"]["aws:minute"]["number"].to_i,
        data["aws:ob_date"]["aws:second"]["number"].to_i
      ) if data && data["aws:ob_date"]
    end

    def self._build_timezone(data)
      if data && data["aws:ob_date"] && data["aws:ob_date"]["aws:time_zone"]
        Data::Zone.new(data["aws:ob_date"]["aws:time_zone"]["abbrv"])
      end
    end

    def self._build_current(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)

      current = Measurement::Current.new
      # current.updated_at = Data::LocalDateTime.parse(data['observation_time']) if data['observation_time']
      current.humidity = data['aws:humidity'].to_i
      current.condition = data['aws:current_condition'] if data['aws:current_condition']
      current.icon = data['aws:icon'].to_i.to_s if data['aws:icon']

      current.temperature = Data::Temperature.new(metric)
      current.temperature << data['aws:temp']

      current.wind = Data::Speed.new(metric)
      current.wind << data['aws:wind_speed'].to_f
      current.wind.direction = data['aws:wind_direction']

      current.pressure = Data::Pressure.new(metric)
      current.pressure << data['aws:pressure']

      current.dew_point = Data::Temperature.new(metric)
      current.dew_point << data['aws:dew_point']

      current.wind_chill = Data::Temperature.new(metric)
      current.wind_chill << data['aws:feels_like']

      current
    end
    
    def self._build_forecast(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      forecasts = Measurement::ResultArray.new
      # go through each forecast and create an instance
      if data && data["aws:forecast"]
        start_date = Date.parse(data['date'])
        i = 0
        data["aws:forecast"].each do |forecast|
          forecast_measurement = Measurement::Forecast.new
          icon_match = forecast['aws:image'].match(/cond(\d*)\.gif$/)
          forecast_measurement.icon = icon_match[1].to_i.to_s if icon_match
          forecast_measurement.date = start_date + i
          forecast_measurement.condition = forecast['aws:short_prediction']

          forecast_measurement.high = Data::Temperature.new(metric)
          forecast_measurement.high << forecast['aws:high']

          forecast_measurement.low = Data::Temperature.new(metric)
          forecast_measurement.low << forecast['aws:low']

          forecasts << forecast_measurement
          i += 1
        end
      end
      forecasts
    end
    
    def self._build_location(data, geo=nil)
      raise ArgumentError unless data.is_a?(Hash)
      raise ArgumentError unless (geo.nil? || geo.is_a?(Data::Geo))
      location = Data::Location.new
      # use the geocoded data if available, otherwise get data from result
      if geo
        location.city = geo.locality
        location.state_code = geo.region
        location.country = geo.country
        location.country_code = geo.country_code
        location.latitude = geo.latitude
        location.longitude = geo.longitude
      else
        if data && data['aws:location']
          location.city = data['aws:location']['aws:city']
          location.state_code = data['aws:location']['aws:state']
          location.zip_code = data['aws:location']['aws:zip']
        end
      end
      location
    end
    
    def self._build_station(data)
      raise ArgumentError unless data.is_a?(Hash)
      station = Data::Location.new
      station.id = data['aws:station_id']
      station.name = data['aws:station']
      station.city = data['aws:city_state'].split(',')[0].strip
      station.state_code = data['aws:city_state'].split(',')[1].strip
      station.country = data['aws:country']
      station.zip_code = data['aws:station_zipcode']
      station.latitude = data['aws:latitude']
      station.longitude = data['aws:longitude']
      station
    end
    
    def self._build_sun(data)
      raise ArgumentError unless data.is_a?(Hash)
      sun = nil
      if data
        if data['aws:sunrise']
          rise = Data::LocalTime.new(
            data['aws:sunrise']['aws:hour']['hour_24'].to_i,
            data['aws:sunrise']['aws:minute']['number'].to_i,
            data['aws:sunrise']['aws:second']['number'].to_i
          )
        end
        if data['aws:sunset']
          set = Data::LocalTime.new(
            data['aws:sunset']['aws:hour']['hour_24'].to_i,
            data['aws:sunset']['aws:minute']['number'].to_i,
            data['aws:sunset']['aws:second']['number'].to_i
          )
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
      result << _fetch_current(query,metric)
      result << _fetch_forecast(query,metric)
      result
    end
    
    # use HTTParty to get the current weather
    #
    def self._fetch_current(query, metric=true)
      puts "fetch weatherbug current: #{query.q}" if Barometer::debug?
      
      q = ( query.format.to_sym == :short_zipcode ?
        { :zipCode => query.q } :
        { :lat => query.q.split(',')[0], :long => query.q.split(',')[1] })
      
      # httparty and the xml builder it uses miss some information
      # 1st - get the raw response
      # 2nd - manually get the missing information
      # 3rd - let httparty build xml as normal
      #
      response = self.get(
        "http://#{@@api_code}.api.wxbug.net/getLiveWeatherRSS.aspx",
        :query => { :ACode => @@api_code,
          :OutputType => "1", :UnitType => (metric ? '1' : '0')
        }.merge(q),
        :format => :plain,
        :timeout => Barometer.timeout
      )
      
      # get icon
      icon_match = response.match(/cond(\d*)\.gif/)
      icon = icon_match[1] if icon_match
      
      # get station zipcode
      zip_match = response.match(/zipcode=\"(\d*)\"/)
      zipcode = zip_match[1] if zip_match
      
      # build xml
      output = Crack::XML.parse(response)
      output = output["aws:weather"]["aws:ob"]
      
      # add missing data
      output["aws:icon"] = icon
      output["aws:station_zipcode"] = zipcode
      
      output
    end
    
    # use HTTParty to get the current weather
    #
    def self._fetch_forecast(query, metric=true)
      puts "fetch weatherbug forecast: #{query.q}" if Barometer::debug?
      
      q = ( query.format.to_sym == :short_zipcode ?
        { :zipCode => query.q } :
        { :lat => query.q.split(',')[0], :long => query.q.split(',')[1] })
      
      self.get(
        "http://#{@@api_code}.api.wxbug.net/getForecastRSS.aspx",
        :query => { :ACode => @@api_code,
          :OutputType => "1", :UnitType => (metric ? '1' : '0')
        }.merge(q),
        :format => :xml,
        :timeout => Barometer.timeout
      )["aws:weather"]["aws:forecasts"]
    end
    
    # since we have two sets of data, override these calls to choose the
    # right set of data
    #
    def self._current_result(data); data[0]; end
    def self._forecast_result(data=nil); data[1]; end
    def self._location_result(data=nil); data[1]; end
    def self._station_result(data=nil); data[0]; end
    def self._sun_result(data=nil); data[0]; end
    def self._timezone_result(data=nil); data[0]; end
    def self._time_result(data=nil); data[0]; end

  end
end