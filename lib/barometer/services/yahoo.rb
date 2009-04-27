module Barometer
  #
  # Yahoo Weather
  # www.yahoo.com
  #
  # key required: NO
  # registration required: NO
  # supported countries: US (by zipcode), International (by Yahoo Location ID)
  #
  # performs geo coding
  # city: YES
  # coordinates: YES
  #
  # timezone info
  # provides zone: NO (just short version)
  # NOTE: since this only supports US, the short version can be used to get
  #       full timezone (until yahoo location id support is added)
  #
  # API: http://developer.yahoo.com/weather/
  #
  # Possible queries:
  # http://weather.yahooapis.com/forecastrss?p=94089
  # http://weather.yahooapis.com/forecastrss?p=USCA1116
  # http://weather.yahooapis.com/forecastrss?p=FRXX0076&u=c
  #
  # where query can be:
  #
  #    * zipcode (US)
  #    * Yahoo Location ID (International) - not currently supported
  #
  # NOTE: the Yahoo Location ID is a propreitary number (possibly shared with weather.com)
  #       so this driver currently does not provide a way to get/use this number,
  #       therefore International support is currently missing
  #
  class Yahoo < Service
    
    def self.accepted_formats
      [:zipcode]
    end
    
    def self.source_name
      :yahoo
    end
    
    # override, only currently supports US
    def self.supports_country?(query=nil)
      query && query.country_code && query.country_code.downcase == "us"
    end

    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless query.is_a?(Barometer::Query)
      measurement.source = self.source_name
    
      # get measurement
      begin
        result = self.get_all(query.preferred, metric)
      rescue Timeout::Error => e
        return measurement
      end
      
      # build current
      current_measurement = self.build_current(result, metric)
      measurement.success! if
        (current_measurement.temperature && !current_measurement.temperature.c.nil?)
      measurement.current = current_measurement
      
      # build forecast
      forecast_measurements = self.build_forecast(result, metric)
      measurement.forecast = forecast_measurements
      
      # build extra data
      measurement.location = self.build_location(result, query.geo)
      #measurement.timezone = self.build_timezone(forecast_result)
    
      measurement
    end
    
    def self.build_current(current_result, metric=true)
      raise ArgumentError unless current_result.is_a?(Hash)
      
      current = CurrentMeasurement.new
      
      # create shortcuts
      if current_result
        if current_result['item'] && current_result['item']['yweather:condition']
          condition_result = current_result['item']['yweather:condition']
        end
        atmosphere_result = current_result['yweather:atmosphere'] if current_result['yweather:atmosphere']
        wind_result = current_result['yweather:wind'] if current_result['yweather:wind']
      end
      
      current.local_time = condition_result['date'] if condition_result
      current.humidity = atmosphere_result['humidity'].to_i if atmosphere_result
      current.icon = condition_result['code'] if condition_result
      #current.condition = condition_result['text'] if condition_result

      temp = Temperature.new(metric)
      if metric
        temp.c = condition_result['temp'].to_f if condition_result
      else
        temp.f = condition_result['temp'].to_f if condition_result
      end
      current.temperature = temp

      wind = Speed.new(metric)
      if metric
        wind.kph = wind_result['speed'].to_f if wind_result
      else
        wind.mph = wind_result['speed'].to_f if wind_result
      end
      wind.degrees = wind_result['degrees'].to_f if wind_result
      current.wind = wind

      pressure = Pressure.new(metric)
      if metric
        pressure.mb = atmosphere_result['pressure'].to_f if atmosphere_result
      else
        pressure.in = atmosphere_result['pressure'].to_f if atmosphere_result
      end
      current.pressure = pressure

      wind_chill = Temperature.new(metric)
      if metric
        wind_chill.c = wind_result['chill'].to_f if wind_result
      else
        wind_chill.f = wind_result['chill'].to_f if wind_result
      end
      current.wind_chill = wind_chill

      visibility = Distance.new(metric)
      if metric
        visibility.km = atmosphere_result['visibility'].to_f if atmosphere_result
      else
        visibility.m = atmosphere_result['visibility'].to_f if atmosphere_result
      end
      current.visibility = visibility

      current
    end
    
    def self.build_forecast(forecast_result, metric=true)
      raise ArgumentError unless forecast_result.is_a?(Hash)
      
      forecasts = []
      if forecast_result && forecast_result['item'] &&
        forecast_result['item']['yweather:forecast']
        
        forecast_result = forecast_result['item']['yweather:forecast']
        
        # go through each forecast and create an instance
        forecast_result.each do |forecast|
          forecast_measurement = ForecastMeasurement.new
            
          forecast_measurement.icon = forecast['code']
          forecast_measurement.date = Date.parse(forecast['date'])
            
          high = Temperature.new(metric)
          if metric
            high.c = forecast['high'].to_f
          else
            high.f = forecast['high'].to_f
          end
          forecast_measurement.high = high
            
          low = Temperature.new(metric)
          if metric
            low.c = forecast['low'].to_f
          else
            low.f = forecast['low'].to_f
          end
          forecast_measurement.low = low
        
          #forecast_measurement.condition = forecast['text']
            
          forecasts << forecast_measurement
        end
        
      end
    
      forecasts
    end
    
    def self.build_location(location_result, geo=nil)
      raise ArgumentError unless location_result.is_a?(Hash)
      raise ArgumentError unless (geo.nil? || geo.is_a?(Barometer::Geo))
      
      location = Location.new
      if geo
        location.city = geo.locality
        location.state_code = geo.region
        location.country = geo.country
        location.country_code = geo.country_code
        location.latitude = geo.latitude
        location.longitude = geo.longitude
      else
        if location_result && location_result['yweather:location']
          location.city = location_result['yweather:location']['city']
          location.state_code = location_result['yweather:location']['region']
          location.country_code = location_result['yweather:location']['country']
          if location_result['item']
            location.latitude = location_result['item']['geo:lat']
            location.longitude = location_result['item']['geo:long']
          end
        end
      end
      
      location
    end

    # def self.build_timezone(timezone_result)
    #   raise ArgumentError unless timezone_result.is_a?(Hash)
    #   
    #   timezone = nil
    #   if timezone_result && timezone_result['simpleforecast'] &&
    #      timezone_result['simpleforecast']['forecastday'] &&
    #      timezone_result['simpleforecast']['forecastday'].first &&
    #      timezone_result['simpleforecast']['forecastday'].first['date']
    #     timezone = Barometer::Zone.new(Time.now.utc,timezone_result['simpleforecast']['forecastday'].first['date']['tz_long'])
    #   end
    #   timezone
    # end
    
    # use HTTParty to get the current weather
    def self.get_all(query, metric=true)
      Barometer::Yahoo.get(
        "http://weather.yahooapis.com/forecastrss",
        :query => {:p => query, :u => (metric ? 'c' : 'f')},
        :format => :xml,
        :timeout => Barometer.timeout
      )['rss']['channel']
    end
    
  end
end