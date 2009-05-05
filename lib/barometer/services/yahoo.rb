module Barometer
  #
  # = Yahoo! Weather
  # www.yahoo.com
  #
  # - key required: NO
  # - registration required: NO
  # - supported countries: US (by zipcode), International (by Yahoo Location ID)
  #
  # === performs geo coding
  # - city: YES
  # - coordinates: YES
  #
  # === time info
  # - sun rise/set: YES (today only)
  # - provides timezone: PARTIAL (just short code)
  # - requires TZInfo: NO
  #
  # == resources
  # - API: http://developer.yahoo.com/weather/
  #
  # === Possible queries:
  # - http://weather.yahooapis.com/forecastrss?p=94089
  # - http://weather.yahooapis.com/forecastrss?p=USCA1116
  # - http://weather.yahooapis.com/forecastrss?p=FRXX0076&u=c
  #
  # where query can be:
  # - zipcode (US)
  # - Yahoo! Location ID [actually weather.com id] (International)
  #
  # = Yahoo! terms of use
  # The feeds are provided free of charge for use by individuals and non-profit
  # organizations for personal, non-commercial uses. We ask that you provide
  # attribution to Yahoo! Weather in connection with your use of the feeds.
  # If you provide this attribution in text, please use: "Yahoo! Weather." If you
  # provide this attribution with a graphic, please use the Yahoo! Weather logo that
  # we have included in the feed itself.
  # We reserve all rights in and to the Yahoo! Weather logo, and your right to use
  # the Yahoo! Weather logo is limited to providing attribution in connection with
  # these RSS feeds. Yahoo! also reserves the right to require you to cease
  # distributing these feeds at any time for any reason.
  #
  # == notes
  # - the Yahoo! Location ID is a propreitary number (shared with weather.com)
  #
  class Yahoo < Service
    
    def self.accepted_formats
      [:zipcode, :weather_id]
    end
    
    def self.source_name
      :yahoo
    end
    
    # these are the icon codes that indicate "wet", used by wet? function
    def self.wet_icon_codes
      codes = [1] + (3..18).to_a + [35] + (37..43).to_a + (45..47).to_a
      codes.collect {|c| c.to_s}
    end
    def self.sunny_icon_codes
      codes = (29..34).to_a + [36]
      codes.collect {|c| c.to_s}
    end

    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless query.is_a?(Barometer::Query)
      measurement.source = self.source_name
      
      begin
        result = self.get_all(query.preferred, metric)
      rescue Timeout::Error => e
        return measurement
      end
      
      measurement.current = self.build_current(result, metric)
      measurement.forecast = self.build_forecast(result, metric)
      measurement.location = self.build_location(result, query.geo)
      
      # add links
      if result["title"] && result["link"]
        measurement.links[result["title"]] = result["link"]
      end
      
      # add to current
      sun = nil
      if measurement.current
        sun = self.build_sun(result)
        measurement.current.sun = sun
      end
      # use todays sun data for all future days
      if measurement.forecast && sun
        measurement.forecast.each do |forecast|
          forecast.sun = sun
        end
      end
      
# save the local time
local_time = self.build_local_time(result)
if local_time
  measurement.measured_at = local_time
  measurement.current.current_at = local_time
end
      
      measurement
    end
    
def self.build_local_time(data)
  if data
    if data['item']
      # what time is it now?
      now_utc = Time.now.utc
      
      # get published date
      pub_date = data['item']['pubDate']
      
      # get the TIME ZONE CODE
      zone_match = data['item']['pubDate'].match(/ ([A-Z]*)$/)
      zone = zone_match[1] if zone_match
      
      # try converting pub_date to utc
      pub_date_utc = Data::Zone.code_to_utc(Time.parse(pub_date), zone)
      
      # how far back was this?
      data_age_in_seconds = now_utc - pub_date_utc
      
      # is this older then 2 hours
      if (data_age_in_seconds < 0) || (data_age_in_seconds > (60 * 60 * 2))
        # we may have converted the time wrong.
        # if pub_date in the future, then?
        # if pub_date too far back, then?
        
        # for now do nothing ... don't set measured_time
        return nil
      else
        # everything seems fine
        # convert now to the local time 
        offset = Data::Zone.zone_to_offset(zone)
        return Data::LocalTime.parse(now_utc + offset)
      end
      nil
    end
  end
end
    
    def self.build_current(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      current = Data::CurrentMeasurement.new
      if data
        if data['item'] && data['item']['yweather:condition']
          condition_result = data['item']['yweather:condition']
          current.updated_at = Data::LocalDateTime.parse(condition_result['date'])
          current.icon = condition_result['code']
          current.condition = condition_result['text']
          current.temperature = Data::Temperature.new(metric)
          current.temperature << condition_result['temp']
        end
        if data['yweather:atmosphere']
          atmosphere_result = data['yweather:atmosphere']
          current.humidity = atmosphere_result['humidity'].to_i
          current.pressure = Data::Pressure.new(metric)
          current.pressure << atmosphere_result['pressure']
          current.visibility = Data::Distance.new(metric)
          current.visibility << atmosphere_result['visibility']
        end
        if data['yweather:wind']
          wind_result = data['yweather:wind']
          current.wind = Data::Speed.new(metric)
          current.wind << wind_result['speed']
          current.wind.degrees = wind_result['degrees'].to_f
          current.wind_chill = Data::Temperature.new(metric)
          current.wind_chill << wind_result['chill']
        end
      end
      current
    end
    
    def self.build_forecast(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      forecasts = []
      
      if data && data['item'] && data['item']['yweather:forecast']
         forecast_result = data['item']['yweather:forecast']
         
        forecast_result.each do |forecast|
          forecast_measurement = Data::ForecastMeasurement.new
          forecast_measurement.icon = forecast['code']
          forecast_measurement.date = Date.parse(forecast['date'])
          forecast_measurement.condition = forecast['text']
          forecast_measurement.high = Data::Temperature.new(metric)
          forecast_measurement.high << forecast['high'].to_f
          forecast_measurement.low = Data::Temperature.new(metric)
          forecast_measurement.low << forecast['low'].to_f
          forecasts << forecast_measurement
        end
      end
      forecasts
    end
    
    def self.build_location(data, geo=nil)
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
        if data && data['yweather:location']
          location.city = data['yweather:location']['city']
          location.state_code = data['yweather:location']['region']
          location.country_code = data['yweather:location']['country']
          if data['item']
            location.latitude = data['item']['geo:lat']
            location.longitude = data['item']['geo:long']
          end
        end
      end
      location
    end
    
    def self.build_sun(data)
      raise ArgumentError unless data.is_a?(Hash)
      # sun = nil
      # if data && data['yweather:astronomy'] && data['item']
      #   # get the TIME ZONE CODE
      #   zone_match = data['item']['pubDate'].match(/ ([A-Z]*)$/)
      #   zone = zone_match[1] if zone_match
      #   # get the sun rise and set
      #   rise = Barometer::Zone.merge(
      #     data['yweather:astronomy']['sunrise'],
      #     data['item']['pubDate'],
      #     zone
      #   )
      #   set = Barometer::Zone.merge(
      #     data['yweather:astronomy']['sunset'],
      #     data['item']['pubDate'],
      #     zone
      #   )
      #   sun = Data::Sun.new(rise, set)
      # end
      # sun || Data::Sun.new
      
      sun = nil
      if data && data['yweather:astronomy'] && data['item']
        local_rise = Data::LocalTime.parse(data['yweather:astronomy']['sunrise'])
        local_set = Data::LocalTime.parse(data['yweather:astronomy']['sunset'])
        sun = Data::Sun.new(local_rise, local_set)
      end
      sun || Data::Sun.new
    end

    # def self.build_timezone(data)
    #   raise ArgumentError unless data.is_a?(Hash)
    #   
    #   timezone = nil
    #   if data && data['simpleforecast'] &&
    #      data['simpleforecast']['forecastday'] &&
    #      data['simpleforecast']['forecastday'].first &&
    #      data['simpleforecast']['forecastday'].first['date']
    #     timezone = Barometer::Zone.new(Time.now.utc,data['simpleforecast']['forecastday'].first['date']['tz_long'])
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