module Barometer
  #
  # = Weather.com
  # www.weather.com
  #
  # - usage restrictions: YES ... many !!!
  # - key required: YES (partnerid & licensekey)
  # - registration required: YES
  # - supported countries: US (by zipcode), International (by Weather Location ID)
  #
  # === performs geo coding
  # - city: PARTIAL (just a name)
  # - coordinates: YES
  #
  # === time info
  # - sun rise/set: YES
  # - provides timezone: NO, but provides a utc offset
  # - requires TZInfo: NO
  #
  # == resources
  # - API: ?
  #
  # === Possible queries:
  # - http://xoap.weather.com/weather/local/30339?cc=*&dayf=5&link=xoap&prod=xoap&par=[PartnerID]&key=[LicenseKey]
  #
  # where query can be:
  # - zipcode (US) [5 digits only]
  # - Weather Location ID (International)
  #
  # = Weather.com terms of use
  # There are many conditions when using weather.com. Please read the EULA you
  # received when you registered for your API keys.  In a nutshell (but not limited
  # to), do the following:
  # - display the weather.com links (all 5)
  # - respect the data refresh rates
  # - do not alter/delete content
  # - display when weather was last updated
  # - do not display data in combination with other 3rd party data (except NOAA or GOV)
  # - do not reproduce, rent, lease, lend, distribute or re-market data
  # - do not resell
  # - do not use in combination with a service that charges a fee
  # - do not use in a mobile application
  # - use the images properly
  # - do not display weather for more then 3 locations at a time
  # - do not allow the data to be scraped (via robots, spiders, web crawlers, etc)
  # - do not use the latitude and longitude information
  #
  # == notes
  # - the Weather Location ID is a propreitary number (shared with yahoo.com)
  #
  # == TODO
  # - improve "forecasted_wet_by_icon?" to determine if day or night and use right code
  # - improve "forecasted_sunny_by_icon?" to determine if day or night and use right code
  # - improve "forcasted_wet_by_humidity?" to use forecasted values
  # - improve "forcasted_windy?" to use forecasted values
  # - collect moon and uv information
  #
  class WeatherService::WeatherDotCom < WeatherService
    
    @@partner_key = nil
    @@license_key = nil

    def self.keys=(keys)
      raise ArgumentError unless keys.is_a?(Hash)
      keys.each do |key, value|
        @@partner_key = value.to_s if key.to_s.downcase == "partner"
        @@license_key = value.to_s if key.to_s.downcase == "license"
      end
    end

    #########################################################################
    # PRIVATE
    # If class methods could be private, the remaining methods would be.
    #

    def self._source_name; :weather_dot_com; end
    def self._accepted_formats; [:short_zipcode, :weather_id]; end

    def self._has_keys?; !@@partner_key.nil? && !@@license_key.nil?; end
    def self._requires_keys?; true; end

    def self._wet_icon_codes
      codes = (0..18).to_a + [35] + (37..43).to_a + (45..47).to_a
      codes.collect {|c| c.to_s}
    end
    def self._sunny_icon_codes
      codes = [19, 22, 28, 30, 32, 34, 36]
      codes.collect {|c| c.to_s}
    end

    # first try to match the zone code, otherwise use the zone offset
    #
    def self._build_timezone(data)
      if data
        if data['cc'] && data['cc']['lsup'] &&
           (zone_match = data['cc']['lsup'].match(/ ([A-Z]{1,4})$/))
          Data::Zone.new(zone_match[1])
        elsif data['loc'] && data['loc']['zone']
          Data::Zone.new(data['loc']['zone'].to_f)
        end
      end
    end
    
    def self._parse_local_time(data)
      (data && data['loc']) ? Data::LocalTime.parse(data['loc']['tm']) : nil
    end

    def self._build_links(data)
      links = {}
      if data && data['lnks'] && data['lnks']['link']
        data['lnks']['link'].each do |link_hash|
          links[link_hash['t']] = link_hash['l']
        end
      end
      links
    end

    def self._build_current(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      current = Measurement::Result.new
      if data
        if data['cc']
          current.updated_at = Data::LocalDateTime.parse(data['cc']['lsup'])
          current.icon = data['cc']['icon']
          current.condition = data['cc']['t']
          current.humidity = data['cc']['hmid'].to_i
          current.temperature = Data::Temperature.new(metric)
          current.temperature << data['cc']['tmp']
          current.dew_point = Data::Temperature.new(metric)
          current.dew_point << data['cc']['dewp']
          current.wind_chill = Data::Temperature.new(metric)
          current.wind_chill << data['cc']['flik']
          current.visibility = Data::Distance.new(metric)
          current.visibility << data['cc']['vis']
          if data['cc']['wind']
            current.wind = Data::Speed.new(metric)
            current.wind << data['cc']['wind']['s']
            current.wind.degrees = data['cc']['wind']['d'].to_f
            current.wind.direction = data['cc']['wind']['t']
          end
          if data['cc']['bar']
            current.pressure = Data::Pressure.new(metric)
            current.pressure << data['cc']['bar']['r']
          end
        end
      end
      current
    end
    
    def self._build_forecast(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)
      forecasts = Measurement::ResultArray.new
    
      if data && data['dayf'] && data['dayf']['day']
        local_date = data['dayf']['lsup']
        data['dayf']['day'].each do |forecast|
          day_measurement = Measurement::Result.new
          night_measurement = Measurement::Result.new
          
          # as stated by weather.com "day = 7am-7pm"
          # and "night = 7pm-7am"
          date = Date.parse(forecast['dt'])
          date_string = date.strftime("%b %d")
          day_measurement.valid_start_date = Data::LocalDateTime.new(date.year,date.month,date.day,7,0,0)
          day_measurement.valid_end_date = Data::LocalDateTime.new(date.year,date.month,date.day,18,59,59)
          night_measurement.valid_start_date = Data::LocalDateTime.new(date.year,date.month,date.day,19,0,0)
          night_measurement.valid_end_date = Data::LocalDateTime.new(date.year,date.month,date.day+1,6,59,59)
          
          high = Data::Temperature.new(metric)
          high << forecast['hi']
          low = Data::Temperature.new(metric)
          low << forecast['low']
          day_measurement.high = high
          day_measurement.low = low
          night_measurement.high = high
          night_measurement.low = low
          
          # build sun
          rise_local_time = Data::LocalTime.parse(forecast['sunr'])
          set_local_time = Data::LocalTime.parse(forecast['suns'])
          sun = Data::Sun.new(rise_local_time, set_local_time)
          day_measurement.sun = sun
          night_measurement.sun = sun
          
          if forecast['part']
            forecast['part'].each do |part|
              if part['p'] == 'd'
                # add this to the day
                day_measurement.description = "#{date_string} - Day"
                day_measurement.condition = part['t']
                day_measurement.icon = part['icon']
                day_measurement.pop = part['ppcp'].to_i
                day_measurement.humidity = part['hmid'].to_i
                
                if part['wind']
                  day_measurement.wind = Data::Speed.new(metric)
                  day_measurement.wind << part['wind']['s']
                  day_measurement.wind.degrees = part['wind']['d'].to_i
                  day_measurement.wind.direction = part['wind']['t']
                end
                
              elsif part['p'] == 'n'  
                # add this to the night
                night_measurement.description = "#{date_string} - Night"
                night_measurement.condition = part['t']
                night_measurement.icon = part['icon']
                night_measurement.pop = part['ppcp'].to_i
                night_measurement.humidity = part['hmid'].to_i
                
                if part['wind']
                  night_measurement.wind = Data::Speed.new(metric)
                  night_measurement.wind << part['wind']['s']
                  night_measurement.wind.degrees = part['wind']['d'].to_i
                  night_measurement.wind.direction = part['wind']['t']
                end
                
              end
            end
          end
          forecasts << day_measurement
          forecasts << night_measurement
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
        if data && data['loc']
          location.name = data['loc']['dnam']
          location.latitude = data['loc']['lat']
          location.longitude = data['loc']['lon']
        end
      end
      location
    end
    
    def self._build_sun(data)
      raise ArgumentError unless data.is_a?(Hash)
      sun = nil
      if data
        if data['loc']
          rise_local_time = Data::LocalTime.parse(data['loc']['sunr'])
          set_local_time = Data::LocalTime.parse(data['loc']['suns'])
        end  
        sun = Data::Sun.new(rise_local_time, set_local_time)
      end
      sun || Data::Sun.new
    end

    # use HTTParty to get the current weather
    #
    def self._fetch(query, metric=true)
      return unless query
      puts "fetch weather.com: #{query.q}" if Barometer::debug?
      result = self.get(
        "http://xoap.weather.com/weather/local/#{query.q}",
        :query => { :par => @@partner_key, :key => @@license_key,
          :prod => "xoap", :link => "xoap", :cc => "*",
          :dayf => "5", :unit => (metric ? 'm' : 's')
        },
        :format => :xml,
        :timeout => Barometer.timeout
      )
      puts result.inspect
      result['weather']
    end
    
  end
end