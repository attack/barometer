require 'rubygems'
require 'httparty'

$:.unshift(File.dirname(__FILE__))
# load some changes to Httparty
require 'extensions/httparty'

module Barometer
  #
  # Service Class
  #
  # This is a base class for creating alternate weather api-consuming
  # drivers.  Each driver inherits from this class.
  # 
  # Basically, all a service is required to do is take a query
  # (ie "Paris") and return a complete Data::Measurement instance.
  #
  class WeatherService
    # all service drivers will use the HTTParty gem
    include HTTParty
    
    # retrieves the weather source Service object
    def self.source(source_name)
      raise ArgumentError unless (source_name.is_a?(String) || source_name.is_a?(Symbol))
      source_name = source_name.to_s.split("_").collect{ |s| s.capitalize }.join('')
      raise ArgumentError unless Barometer::WeatherService.const_defined?(source_name)
      raise ArgumentError unless Barometer::WeatherService.const_get(source_name).superclass == Barometer::WeatherService
      Barometer::WeatherService.const_get(source_name)
    end

    #
    # get current weather and future (forecasted) weather
    #
    def self.measure(query, metric=true)
      raise ArgumentError unless query.is_a?(Barometer::Query)
      
      measurement = Data::Measurement.new(self._source_name, metric)
      if self._meets_requirements?(query)
        converted_query = query.convert!(self._accepted_formats)
        if converted_query
          measurement.source = self._source_name
          measurement.query = converted_query.q
          measurement.format = converted_query.format
          measurement = self._measure(measurement, converted_query, metric)
        end
      end
      measurement
    end
    
    # simple questions
    #
    
    def self.windy?(measurement, threshold=10, time_string=nil)
      local_time = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (local_time.is_a?(Data::LocalDateTime) || local_time.nil?)

      measurement.current?(local_time) ?
        self._currently_windy?(measurement, threshold) :
        self._forecasted_windy?(measurement, threshold, local_time)
    end
    
    def self.wet?(measurement, threshold=50, time_string=nil)
      local_time = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (local_time.is_a?(Data::LocalDateTime) || local_time.nil?)
      measurement.current?(local_time) ?
        self._currently_wet?(measurement, threshold) :
        self._forecasted_wet?(measurement, threshold, local_time)
    end
    
    def self.day?(measurement, time_string=nil)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)

      measurement.current?(local_datetime) ?
        self._currently_day?(measurement) :
        self._forecasted_day?(measurement, local_datetime)
    end
    
    def self.sunny?(measurement, time_string=nil)
      local_time = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (local_time.is_a?(Data::LocalDateTime) || local_time.nil?)
      measurement.current?(local_time) ?
        self._currently_sunny?(measurement) :
        self._forecasted_sunny?(measurement, local_time)
    end
    
    # PRIVATE
    # If class methods could be private, the remaining methods would be.
    #
    
    def self._meets_requirements?(query=nil)
      self._supports_country?(query) && (!self._requires_keys? || self._has_keys?)
    end
    
    #
    # NOTE: The following methods MUST be re-defined by each driver.
    #
    
    # STUB: define this method to actually retireve the source_name
    def self._source_name; raise NotImplementedError; end

    # STUB: define this method to indicate what query formats are accepted
    def self._accepted_formats; raise NotImplementedError; end
    
    #
    # NOTE: The following methods can be re-defined by each driver. [OPTIONAL]
    #

    # this is the generic measuring and data processing for each weather service
    # driver.  this method should be re-defined if the driver in question
    # doesn't fit into "generic" (ie wunderground)
    #
    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless query.is_a?(Barometer::Query)
  
      begin
        result = _fetch(query.q, metric)
      rescue Timeout::Error => e
        return measurement
      end
  
      if result
        measurement.current = _build_current(_current_result(result), metric)
        measurement.forecast = _build_forecast(_forecast_result(result), metric)
        measurement.location = _build_location(_location_result(result), query.geo)
        measurement.station = _build_station(_station_result(result))
        measurement.links = _build_links(_links_result(result))
        measurement.current.sun = _build_sun(_sun_result(result)) if measurement.current
        measurement.timezone = _timezone(_timezone_result(result), measurement.location)
        if local_time = _local_time(_time_result(result), measurement)
           measurement.measured_at = local_time
           measurement.current.current_at = local_time
        end
        measurement = _build_extra(measurement, result, metric)
      end
  
      measurement
    end
    
    def self._current_result(data=nil); data; end
    def self._forecast_result(data=nil); data; end
    def self._location_result(data=nil); data; end
    def self._station_result(data=nil); data; end
    def self._links_result(data=nil); data; end
    def self._sun_result(data=nil); data; end
    def self._timezone_result(data=nil); data; end
    def self._time_result(data=nil); data; end

    # data processing stubs
    #
    def self._fetch(query=nil, metric=true); nil; end
    def self._build_current(result=nil, metric=true); nil; end
    def self._build_forecast(result=nil, metric=true); nil; end
    def self._build_location(result=nil, geo=nil); nil; end
    def self._build_station(result=nil); Data::Location.new; end
    def self._build_links(result=nil); {}; end
    def self._build_sun(result=nil); Data::Sun.new; end
    def self._build_timezone(result=nil); nil; end
    def self._build_extra(measurement=nil, result=nil, metric=true); measurement; end
    
    # timezone parsing stubs.  there are so many because there are several
    # possible situations
    
    # given the result set, return the full_timezone ... if not available
    # return nil
    def self._parse_full_timezone(result=nil); nil; end
    def self._parse_local_time(result=nil); nil; end
    
    # either get the timezone based on coords, or build it from the data
    #
    def self._timezone(result=nil, location=nil)
      if full_timezone = _parse_full_timezone(result)
        full_timezone
      elsif Barometer.enhance_timezone && location &&
            location.latitude && location.longitude
        WebService::Timezone.fetch(location.latitude, location.longitude)
      else
        _build_timezone(result)
      end
    end
    
    # return the current local time (as Data::LocalTime)
    #
    def self._local_time(result, measurement=nil)
      _parse_local_time(result) || _build_local_time(measurement)
    end
    
    def self._build_local_time(measurement)
      (measurement && measurement.timezone) ? Data::LocalTime.parse(measurement.timezone.now) : nil
    end

    # STUB: define this method to check for the existance of API keys,
    #       this method is NOT needed if requires_keys? returns false
    def self._has_keys?; raise NotImplementedError; end

    # STUB: define this method to check for the existance of API keys,
    #       this method is NOT needed if requires_keys? returns false
    def self._keys=(keys=nil); nil; end

    # DEFAULT: override this if you need to determine if the country is specified
    def self._supports_country?(query=nil); true; end
 
    # DEFAULT: override this if you need to determine if API keys are required
    def self._requires_keys?; false; end
    
    #
    # answer simple questions
    #
    
    #
    # WINDY?
    #
    
    # cookie cutter answer, a driver can override this if they answer it differently
    # if a service doesn't support obtaining the wind value, it will be ignored
    def self._currently_windy?(measurement, threshold=10)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil if (!measurement.current || !measurement.current.wind?)
      measurement.metric? ?
        measurement.current.wind.kph.to_f >= threshold.to_f :
        measurement.current.wind.mph.to_f >= threshold.to_f
    end

    # no driver can currently answer this question, so it doesn't have any code
    def self._forecasted_windy?(measurement, threshold, time_string); nil; end
    
    #
    # WET?
    #
    
    # cookie cutter answer
    def self._currently_wet?(measurement, threshold=50)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless measurement.current
      self._currently_wet_by_icon?(measurement.current) ||
        self._currently_wet_by_dewpoint?(measurement) ||
        self._currently_wet_by_humidity?(measurement.current) ||
        self._currently_wet_by_pop?(measurement, threshold)
    end
    
    # cookie cutter answer
    def self._currently_wet_by_dewpoint?(measurement)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      return nil if (!measurement.current || !measurement.current.temperature? ||
                     !measurement.current.dew_point?)
      measurement.metric? ?
        measurement.current.temperature.c.to_f <= measurement.current.dew_point.c.to_f :
        measurement.current.temperature.f.to_f <= measurement.current.dew_point.f.to_f
    end
    
    # cookie cutter answer
    def self._currently_wet_by_humidity?(current_measurement)
      raise ArgumentError unless current_measurement.is_a?(Data::CurrentMeasurement)
      return nil unless current_measurement.humidity?
      current_measurement.humidity.to_i >= 99
    end
    
    # cookie cutter answer
    def self._currently_wet_by_pop?(measurement, threshold=50)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless measurement.forecast
      # get todays forecast
      forecast_measurement = measurement.for
      return nil unless forecast_measurement
      forecast_measurement.pop.to_f >= threshold.to_f
    end
    
    # cookie cutter answer
    def self._forecasted_wet?(measurement, threshold=50, time_string=nil)
      local_time = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (local_time.is_a?(Data::LocalDateTime) || local_time.nil?)
      return nil unless measurement.forecast
      forecast_measurement = measurement.for(local_time)
      return nil unless forecast_measurement
      self._forecasted_wet_by_icon?(forecast_measurement) ||
        self._forecasted_wet_by_pop?(forecast_measurement, threshold)
    end

    # cookie cutter answer
    def self._forecasted_wet_by_pop?(forecast_measurement, threshold=50)
      raise ArgumentError unless forecast_measurement.is_a?(Data::ForecastMeasurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless forecast_measurement.pop?
      forecast_measurement.pop.to_f >= threshold.to_f
    end

    def self._currently_wet_by_icon?(current_measurement)
      raise ArgumentError unless current_measurement.is_a?(Data::CurrentMeasurement)
      return nil unless self._wet_icon_codes
      return nil unless current_measurement.icon?
      current_measurement.icon.is_a?(String) ?
        self._wet_icon_codes.include?(current_measurement.icon.to_s.downcase) :
        self._wet_icon_codes.include?(current_measurement.icon)
    end
    
    def self._forecasted_wet_by_icon?(forecast_measurement)
      raise ArgumentError unless forecast_measurement.is_a?(Data::ForecastMeasurement)
      return nil unless self._wet_icon_codes
      return nil unless forecast_measurement.icon?
      forecast_measurement.icon.is_a?(String) ?
        self._wet_icon_codes.include?(forecast_measurement.icon.to_s.downcase) :
        self._wet_icon_codes.include?(forecast_measurement.icon)
    end

    # this returns an array of codes that indicate "wet"
    def self._wet_icon_codes; nil; end
    
    #
    # DAY?
    #
    
    def self._currently_day?(measurement)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      return nil unless measurement.current && measurement.current.sun
      self._currently_after_sunrise?(measurement.current) &&
        self._currently_before_sunset?(measurement.current)
    end
    
    def self._currently_after_sunrise?(current_measurement)
      raise ArgumentError unless current_measurement.is_a?(Data::CurrentMeasurement)
      return nil unless current_measurement.current_at && 
        current_measurement.sun && current_measurement.sun.rise
      #Time.now.utc >= current_measurement.sun.rise
      current_measurement.current_at >= current_measurement.sun.rise
    end    

    def self._currently_before_sunset?(current_measurement)
      raise ArgumentError unless current_measurement.is_a?(Data::CurrentMeasurement)
      return nil unless current_measurement.current_at &&
        current_measurement.sun && current_measurement.sun.set
      #Time.now.utc <= current_measurement.sun.set
      current_measurement.current_at <= current_measurement.sun.set
    end

    def self._forecasted_day?(measurement, time_string=nil)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)
      return nil unless measurement.forecast
      forecast_measurement = measurement.for(local_datetime)
      return nil unless forecast_measurement
      self._forecasted_after_sunrise?(forecast_measurement, local_datetime) &&
        self._forecasted_before_sunset?(forecast_measurement, local_datetime)
    end
    
    def self._forecasted_after_sunrise?(forecast_measurement, time_string)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless forecast_measurement.is_a?(Data::ForecastMeasurement)
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)
      return nil unless forecast_measurement.sun && forecast_measurement.sun.rise
      local_datetime >= forecast_measurement.sun.rise
    end 
    
    def self._forecasted_before_sunset?(forecast_measurement, time_string)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless forecast_measurement.is_a?(Data::ForecastMeasurement)
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)
      return nil unless forecast_measurement.sun && forecast_measurement.sun.set
      local_datetime <= forecast_measurement.sun.set
    end
    
    #
    # SUNNY?
    #
    
    # cookie cutter answer
    def self._currently_sunny?(measurement)
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      return nil unless measurement.current
      return false if self._currently_day?(measurement) == false
      self._currently_sunny_by_icon?(measurement.current)
    end
    
    # cookie cutter answer
    def self._forecasted_sunny?(measurement, time_string=nil)
      local_time = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless measurement.is_a?(Data::Measurement)
      raise ArgumentError unless (local_time.is_a?(Data::LocalDateTime) || local_time.nil?)
      return nil unless measurement.forecast
      return false if self._forecasted_day?(measurement, local_time) == false
      forecast_measurement = measurement.for(local_time)
      return nil unless forecast_measurement
      self._forecasted_sunny_by_icon?(forecast_measurement)
    end

    def self._currently_sunny_by_icon?(current_measurement)
      raise ArgumentError unless current_measurement.is_a?(Data::CurrentMeasurement)
      return nil unless self._sunny_icon_codes
      return nil unless current_measurement.icon?
      current_measurement.icon.is_a?(String) ?
        self._sunny_icon_codes.include?(current_measurement.icon.to_s.downcase) :
        self._sunny_icon_codes.include?(current_measurement.icon)
    end
    
    def self._forecasted_sunny_by_icon?(forecast_measurement)
      raise ArgumentError unless forecast_measurement.is_a?(Data::ForecastMeasurement)
      return nil unless self._sunny_icon_codes
      return nil unless forecast_measurement.icon?
      forecast_measurement.icon.is_a?(String) ?
        self._sunny_icon_codes.include?(forecast_measurement.icon.to_s.downcase) :
        self._sunny_icon_codes.include?(forecast_measurement.icon)
    end

    # this returns an array of codes that indicate "sunny"
    def self._sunny_icon_codes; nil; end
    
  end
end  
  
  # def key_name
  #   # what variables holds the api key?
  # end