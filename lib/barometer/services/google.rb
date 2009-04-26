module Barometer
  #
  # NOTE: Google does not have an official API
  #
  # Google Weather
  # www.google.com
  #
  # key required: NO
  # registration required: NO
  # supported countries: ALL
  #
  # API: http://unknown
  #
  # Possible queries:
  #
  # where query can be:
  #
  #    * zipcode (US or Canadian)
  #    * city state; city, state
  #    * city
  #    * state
  #    * country
  #
  # NOTE: google weather doesn't provide any timezone information for the
  #       location.
  #
  class Google < Service
    
    def self.accepted_formats
      [:zipcode, :postalcode, :geocode]
    end
    
    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless query.is_a?(String) || query.nil?
      measurement.source = :google
      return measurement if query.nil?
    
      # get measurement
      result = self.get_all(query)
      
      # build current
      current_measurement = self.build_current(result)
      # TODO: this next line has no test
      measurement.success! if
        (current_measurement.temperature && !current_measurement.temperature.c.nil?)
      measurement.current = current_measurement
      
      # build forecast
      forecast_measurements = self.build_forecast(result)
      measurement.forecast = forecast_measurements
      
      # get time zone info
      #measurement.timezone = self.build_timezone(forecast_result)

      measurement
    end

    def self.build_current(current_result)
      raise ArgumentError unless current_result.is_a?(Hash)
      
      current = CurrentMeasurement.new
      
      if current_result && current_result['forecast_information'] &&
         current_result['forecast_information']['current_date_time']
        current.time = current_result['forecast_information']['current_date_time']['data']
      end
      
      current_result = current_result['current_conditions'] if current_result['current_conditions']

      begin
        current.humidity = current_result['humidity']['data'].match(/[\d]+/)[0].to_i
      rescue
      end
      
      if current_result['icon']
        current.icon = current_result['icon']['data']
      end
      #current.condition = current_result['condition']['data']
      
      temp = Temperature.new
      temp.f = current_result['temp_f']['data'].to_f if current_result['temp_f']
      temp.c = current_result['temp_c']['data'].to_f if current_result['temp_c']
      current.temperature = temp
    
      begin
        wind = Speed.new
        wind.mph = current_result['wind_condition']['data'].match(/[\d]+/)[0].to_i
        wind.direction = current_result['wind_condition']['data'].match(/Wind:.*?([\w]+).*?at/)[1]
        current.wind = wind
      rescue
      end

      current
    end
    
    def self.build_forecast(forecast_result)
      raise ArgumentError unless forecast_result.is_a?(Hash)

      forecasts = []
      return forecasts unless forecast_result && forecast_result['forecast_information'] &&
                              forecast_result['forecast_information']['forecast_date']
      start_date = Date.parse(forecast_result['forecast_information']['forecast_date']['data'])
      forecast_result = forecast_result['forecast_conditions'] if forecast_result['forecast_conditions']

      # go through each forecast and create an instance
      d = 0
      forecast_result.each do |forecast|
        forecast_measurement = ForecastMeasurement.new

        forecast_measurement.icon = forecast['icon']['data']

        if (start_date + d).strftime("%a").downcase == forecast['day_of_week']['data'].downcase
          forecast_measurement.date = start_date + d
        end

        high = Temperature.new
        high.f = forecast['high']['data'].to_f
        forecast_measurement.high = high

        low = Temperature.new
        low.f = forecast['low']['data'].to_f
        forecast_measurement.low = low
        
        #forecast_measurement.condition = forecast['condition']['data']

        forecasts << forecast_measurement
        d += 1
      end

      forecasts
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
    def self.get_all(query)
      Barometer::Google.get(
        "http://google.com/ig/api",
        :query => {:weather => query},
        :format => :xml
      )['xml_api_reply']['weather']
    end
    
  end
end