module Barometer
  class WeatherService::Noaa < WeatherService

    #########################################################################
    # PRIVATE
    # If class methods could be private, the remaining methods would be.
    #

    def self._source_name; :noaa; end
    def self._accepted_formats; [:zipcode, :coordinates]; end

    # we can accept US, or we can try if the country is unknown
    #
    def self._supports_country?(query=nil)
      ["US", nil, ""].include?(query.country_code)
    end

    def self._build_current(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)

      current = Measurement::Result.new
      return current if data.empty?

      if data && data['observation_time_rfc822'] && (time_match = data['observation_time_rfc822'].match(/(.* \d\d:\d\d:\d\d)/))
        current.updated_at = Data::LocalDateTime.parse(time_match[1])
      end

      current.temperature = Data::Temperature.new(metric)
      current.temperature << [data['temp_c'], data['temp_f']]

      current.wind = Data::Speed.new(metric)
      current.wind.mph = data['wind_mph'].to_f
      current.wind.direction = data['wind_dir']
      current.wind.degrees = data['wind_degrees'].to_i

      current.humidity = data['relative_humidity'].to_i

      current.pressure = Data::Pressure.new(metric)
      current.pressure << [data['pressure_mb'], data['pressure_in']]

      current.dew_point = Data::Temperature.new(metric)
      current.dew_point << [data['dewpoint_c'], data['dewpoint_f']]

      if data['windchill_c'] || data['windchill_f']
        current.wind_chill = Data::Temperature.new(metric)
        current.wind_chill << [data['windchill_c'], data['windchill_f']]
      end

      current.visibility = Data::Distance.new(metric)
      current.visibility.m = data['visibility_mi'].to_f

      current.condition = data['weather']
      if data['icon_url_name']
        icon_match = data['icon_url_name'].match(/(.*).(jpg|png)/)
        current.icon = icon_match[1] if icon_match
      end

      current
    end

    def self._build_forecast(data, metric=true)
      raise ArgumentError unless data.is_a?(Hash)

      forecasts = Measurement::ResultArray.new
      return forecasts unless data && data['time_layout']

      twelve_hour_starts = []
      twelve_hour_ends = []
      data['time_layout'].each do |time_layout|
        if time_layout["summarization"] == "24hourly"
          twelve_hour_starts = time_layout["start_valid_time"]
          twelve_hour_ends = time_layout["end_valid_time"]
          break
        end
      end

      daily_highs = []
      daily_lows = []
      data['parameters']['temperature'].each do |temps|
        case temps["type"]
        when "maximum"
          daily_highs = temps['value']
        when "minimum"
          daily_lows = temps['value']
        end
      end

      # NOAA returns 2 pop values for each day ... for each day, use the max pop value
      #
      daily_pops = []
      if data['parameters']['probability_of_precipitation'] &&
        data['parameters']['probability_of_precipitation']['value']
        daily_pops = data['parameters']['probability_of_precipitation']['value'].collect{|i|i.respond_to?(:to_i) ? i.to_i : 0}.each_slice(2).to_a.collect{|x|x.max}
      end

      daily_conditions = []
      if data['parameters']['weather'] &&
        data['parameters']['weather']['weather_conditions']
        daily_conditions = data['parameters']['weather']['weather_conditions'].collect{|c|c["weather_summary"]}
      end

      daily_icons = []
      if data['parameters']['conditions_icon'] &&
        data['parameters']['conditions_icon']['icon_link']
        daily_icons = data['parameters']['conditions_icon']['icon_link'].collect{|c|c.match(/.*\/(.*)\.jpg/)[1]}
      end

      d = 0
      # go through each forecast start date and create an instance
      twelve_hour_starts.each do |start_date|
        forecast_measurement = Measurement::Result.new(metric)

        # day = 6am - 6am (next day)
        date_s = Date.parse(start_date)
        date_e = Date.parse(start_date) + 1
        forecast_measurement.valid_start_date = Data::LocalDateTime.new(date_s.year,date_s.month,date_s.day,6,0,0)
        forecast_measurement.valid_end_date = Data::LocalDateTime.new(date_e.year,date_e.month,date_e.day,5,59,59)

        forecast_measurement.high = Data::Temperature.new(metric)
        forecast_measurement.high.f = (daily_highs[d].respond_to?(:to_f) ? daily_highs[d].to_f : nil)
        forecast_measurement.low = Data::Temperature.new(metric)
        forecast_measurement.low.f = (daily_lows[d].respond_to?(:to_f) ? daily_lows[d].to_f : nil)

        forecast_measurement.pop = daily_pops[d]
        forecast_measurement.condition = daily_conditions[d]
        forecast_measurement.icon = daily_icons[d]

        forecasts << forecast_measurement
        d += 1
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
        if data && data['location']
          location.city = data['location'].split(',')[0].strip
          location.state_code = data['location'].split(',')[-1].strip
          location.country_code = 'US'
        end
      end
      location
    end

    def self._build_station(data)
      raise ArgumentError unless data.is_a?(Hash)
      station = Data::Location.new
      station.id = data['station_id']
      if data['location']
        station.name = data['location']
        station.city = data['location'].split(',')[0].strip
        station.state_code = data['location'].split(',')[-1].strip
        station.country_code = 'US'
        station.latitude = data['latitude']
        station.longitude = data['longitude']
      end
      station
    end

    def self._build_timezone(data)
      if data && data['observation_time']
        zone_match = data['observation_time'].match(/ ([A-Z]*)$/)
        Data::Zone.new(zone_match[1]) if zone_match
      end
    end

    # override default _fetch behavior
    # this service requires TWO seperate http requests (one for current
    # and one for forecasted weather) ... combine the results
    #
    def self._fetch(query, metric=true)
      result = []
      result << _fetch_forecast(query,metric)

      # only proceed if we are getting results
      #
      # binding.pry
      if result[0] && !result[0].empty?
        # we need to use the lst/long from the forecast data (result[0])
        # to get the closest "station_id", to get the current conditions
        #
        station_id = Barometer::WebService::NoaaStation.fetch(
          result[0]["location"]["point"]["latitude"],
          result[0]["location"]["point"]["longitude"]
        )

        result << _fetch_current(station_id,metric)
      else
        puts "NOAA cannot proceed to fetching current weather, lat/lon unknown" if Barometer::debug?
        result << {}
      end

      result
    end

    # use HTTParty to get the current weather
    #
    def self._fetch_current(station_id, metric=true)
      return {} unless station_id
      puts "fetching NOAA current weather: #{station_id}" if Barometer::debug?

      self.get(
        "http://w1.weather.gov/xml/current_obs/#{station_id}.xml",
        :query => {},
        :format => :xml,
        :timeout => Barometer.timeout
      )["current_observation"]
    end

    # use HTTParty to get the forecasted weather
    #
    def self._fetch_forecast(query, metric=true)
      puts "fetching NOAA forecast: #{query.q}" if Barometer::debug?

      q = case query.format.to_sym
      when :short_zipcode
        { :zipCodeList => query.q }
      when :zipcode
        { :zipCodeList => query.q }
      when :coordinates
        { :lat => query.q.split(',')[0], :lon => query.q.split(',')[1] }
      else
        {}
      end

      result = self.get(
        "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php",
        :query => {
          :format => "24 hourly",
          :numDays => "7"
        }.merge(q),
        :format => :xml,
        :timeout => Barometer.timeout
      )


      # binding.pry

      if result && result["dwml"] && result["dwml"]["data"]
        result = result["dwml"]["data"]
      else
        return {}
      end

      # check that we have data ... we have to dig deep to find out since
      # NOAA will return a good looking result, even when there isn't any data to return
      #
      if result && result['parameters'] &&
        result['parameters']['temperature'] &&
        result['parameters']['temperature'].first &&
        result['parameters']['temperature'].first['value'] &&
        !result['parameters']['temperature'].first['value'].collect{|t| t.respond_to?(:to_i) ? t.to_i : nil}.compact.empty?
      else
        return {}
      end

      result
    end

    # since we have two sets of data, override these calls to choose the
    # right set of data
    #
    def self._current_result(data); data[1]; end
    def self._forecast_result(data=nil); data[0]; end
    def self._location_result(data=nil); data[1]; end
    def self._station_result(data=nil); data[1]; end
    def self._sun_result(data=nil); nil; end
    def self._timezone_result(data=nil); data[1]; end
    def self._time_result(data=nil); data[1]; end

  end

end

Barometer::WeatherService.register(:noaa, Barometer::WeatherService::Noaa)
