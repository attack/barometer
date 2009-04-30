module Barometer
  #
  # = Yahoo Weather
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
  # NOTE: since this only supports US, the short code can be used
  #       to convert times (until yahoo location id support is added)
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
  # - Yahoo Location ID (International) - not currently supported
  #
  # == notes
  # - the Yahoo Location ID is a propreitary number (possibly shared with weather.com)
  #   so this driver currently does not provide a way to get/use this number,
  #   therefore International support is currently missing
  #
  class Yahoo < Service
    
    def self.accepted_formats
      [:zipcode]
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
    
    # override, only currently supports US
    def self.supports_country?(query=nil)
      query && query.country_code && query.country_code.downcase == "us"
    end

    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
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
      
      # add to current
      sun = nil
      if measurement.current
        sun = self.build_sun(result)
        measurement.current.sun = sun
      end
      # use todays sun data for all future days
      if measurement.forecast && sun
        start_date = Date.parse(measurement.current.local_time)
        measurement.forecast.each do |forecast|
          days_in_future = forecast.date - start_date
          forecast.sun = Barometer::Sun.add_days!(sun,days_in_future.to_i)
        end
      end
      
      measurement
    end
    
    def self.build_current(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      current = CurrentMeasurement.new
      if data
        if data['item'] && data['item']['yweather:condition']
          condition_result = data['item']['yweather:condition']
          current.local_time = condition_result['date']
          current.icon = condition_result['code']
          current.condition = condition_result['text']
          current.temperature = Temperature.new(metric)
          current.temperature << condition_result['temp']
        end
        if data['yweather:atmosphere']
          atmosphere_result = data['yweather:atmosphere']
          current.humidity = atmosphere_result['humidity'].to_i
          current.pressure = Pressure.new(metric)
          current.pressure << atmosphere_result['pressure']
          current.visibility = Distance.new(metric)
          current.visibility << atmosphere_result['visibility']
        end
        if data['yweather:wind']
          wind_result = data['yweather:wind']
          current.wind = Speed.new(metric)
          current.wind << wind_result['speed']
          current.wind.degrees = wind_result['degrees'].to_f
          current.wind_chill = Temperature.new(metric)
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
          forecast_measurement = ForecastMeasurement.new
          forecast_measurement.icon = forecast['code']
          forecast_measurement.date = Date.parse(forecast['date'])
          forecast_measurement.condition = forecast['text']
          forecast_measurement.high = Temperature.new(metric)
          forecast_measurement.high << forecast['high'].to_f
          forecast_measurement.low = Temperature.new(metric)
          forecast_measurement.low << forecast['low'].to_f
          forecasts << forecast_measurement
        end
      end
      forecasts
    end
    
    def self.build_location(data, geo=nil)
      raise ArgumentError unless data.is_a?(Hash)
      raise ArgumentError unless (geo.nil? || geo.is_a?(Barometer::Geo))
      location = Location.new
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
      sun = nil
      if data && data['yweather:astronomy'] && data['item']
        # get the TIME ZONE CODE
        zone_match = data['item']['pubDate'].match(/ ([A-Z]*)$/)
        zone = zone_match[1] if zone_match
        # get the sun rise and set
        rise = Barometer::Zone.merge(
          data['yweather:astronomy']['sunrise'],
          data['item']['pubDate'],
          zone
        )
        set = Barometer::Zone.merge(
          data['yweather:astronomy']['sunset'],
          data['item']['pubDate'],
          zone
        )
        sun = Sun.new(rise, set)
      end
      sun || Sun.new
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

# Condition Codes
# 0   tornado
# 1   tropical storm
# 2   hurricane
# 3   severe thunderstorms
# 4   thunderstorms
# 5   mixed rain and snow
# 6   mixed rain and sleet
# 7   mixed snow and sleet
# 8   freezing drizzle
# 9   drizzle
# 10  freezing rain
# 11  showers
# 12  showers
# 13  snow flurries
# 14  light snow showers
# 15  blowing snow
# 16  snow
# 17  hail
# 18  sleet
# 19  dust
# 20  foggy
# 21  haze
# 22  smoky
# 23  blustery
# 24  windy
# 25  cold
# 26  cloudy
# 27  mostly cloudy (night)
# 28  mostly cloudy (day)
# 29  partly cloudy (night)
# 30  partly cloudy (day)
# 31  clear (night)
# 32  sunny
# 33  fair (night)
# 34  fair (day)
# 35  mixed rain and hail
# 36  hot
# 37  isolated thunderstorms
# 38  scattered thunderstorms
# 39  scattered thunderstorms
# 40  scattered showers
# 41  heavy snow
# 42  scattered snow showers
# 43  heavy snow
# 44  partly cloudy
# 45  thundershowers
# 46  snow showers
# 47  isolated thundershowers
# 3200  not available