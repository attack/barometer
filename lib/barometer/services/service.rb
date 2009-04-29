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
  # (ie "Paris") and return a complete Barometer::Measurement instance.
  #
  class Service
    
    # all service drivers will use the HTTParty gem
    include HTTParty
    
    # Retrieves the weather source Service object
    def self.source(source_name)
      raise ArgumentError unless (source_name.is_a?(String) || source_name.is_a?(Symbol))
      source_name = source_name.to_s.split("_").collect{ |s| s.capitalize }.join('')
      raise ArgumentError unless Barometer.const_defined?(source_name)
      raise ArgumentError unless Barometer.const_get(source_name).superclass == Barometer::Service
      Barometer.const_get(source_name)
    end

    #
    # get current weather and future (forecasted) weather
    #
    def self.measure(query, metric=true)
      raise ArgumentError unless query.is_a?(Barometer::Query)
      
      measurement = Barometer::Measurement.new(self.source_name, metric)
      if self.meets_requirements?(query)
        query.convert!(self.accepted_formats)
        measurement = self._measure(measurement, query, metric) if query.preferred
      end
      measurement
    end
    
    def self.meets_requirements?(query=nil)
      self.supports_country?(query) && (!self.requires_keys? || self.has_keys?)
    end
    
    #
    # NOTE: The following methods MUST be re-defined by each driver.
    #
    
    # STUB: define this method to indicate what query formats are accepted
    def self.accepted_formats
      raise NotImplementedError
    end
    
    # STUB: define this method to measure the current & future weather
    def self._measure(measurement=nil, query=nil, metric=true)
      raise NotImplementedError
    end

    # STUB: define this method to actually retireve the source_name
    def self.source_name
      raise NotImplementedError
    end

    # STUB: define this method to check for the existance of API keys,
    #       this method is NOT needed if requires_keys? returns false
    def self.has_keys?
      raise NotImplementedError
    end

    #
    # NOTE: The following methods can be re-defined by each driver. [OPTIONAL]
    #

    # DEFAULT: override this if you need to determine if the country is specified
    def self.supports_country?(query=nil)
      true
    end
 
    # DEFAULT: override this if you need to determine if API keys are required
    def self.requires_keys?
      false
    end
    
    #
    # answer simple questions
    #
    
    #
    # WINDY?
    #
    def self.windy?(measurement, threshold=10, utc_time=nil)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (utc_time.is_a?(Time) || utc_time.nil?)

      measurement.current?(utc_time) ?
        self.currently_windy?(measurement, threshold) :
        self.forecasted_windy?(measurement, threshold, utc_time)
    end
    
    # cookie cutter answer, a driver can override this if they answer it differently
    # if a service doesn't support obtaining the wind value, it will be ignored
    def self.currently_windy?(measurement, threshold=10)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil if (!measurement.current || !measurement.current.wind?)
      measurement.metric? ?
        measurement.current.wind.kph.to_f >= threshold.to_f :
        measurement.current.wind.mph.to_f >= threshold.to_f
    end

    # no driver can currently answer this question, so it doesn't have any code
    def self.forecasted_windy?(measurement, threshold, utc_time); nil; end
    
    #
    # WET?
    #
    def self.wet?(measurement, threshold=50, utc_time=nil)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (utc_time.is_a?(Time) || utc_time.nil?)
      measurement.current?(utc_time) ?
        self.currently_wet?(measurement, threshold) :
        self.forecasted_wet?(measurement, threshold, utc_time)
    end
    
    # cookie cutter answer
    def self.currently_wet?(measurement, threshold=50)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless measurement.current
      self.currently_wet_by_icon?(measurement.current) ||
        self.currently_wet_by_dewpoint?(measurement) ||
        self.currently_wet_by_humidity?(measurement.current) ||
        self.currently_wet_by_pop?(measurement, threshold)
    end
    
    # cookie cutter answer
    def self.currently_wet_by_dewpoint?(measurement)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      return nil if (!measurement.current || !measurement.current.temperature? ||
                     !measurement.current.dew_point?)
      measurement.metric? ?
        measurement.current.temperature.c.to_f <= measurement.current.dew_point.c.to_f :
        measurement.current.temperature.f.to_f <= measurement.current.dew_point.f.to_f
    end
    
    # cookie cutter answer
    def self.currently_wet_by_humidity?(current_measurement)
      raise ArgumentError unless current_measurement.is_a?(Barometer::CurrentMeasurement)
      return nil unless current_measurement.humidity?
      current_measurement.humidity.to_i >= 99
    end
    
    # cookie cutter answer
    def self.currently_wet_by_pop?(measurement, threshold=50)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless measurement.forecast
      # get todays forecast
      forecast_measurement = measurement.for
      return nil unless forecast_measurement
      forecast_measurement.pop.to_f >= threshold.to_f
    end
    
    # cookie cutter answer
    def self.forecasted_wet?(measurement, threshold=50, utc_time=nil)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (utc_time.is_a?(Time) || utc_time.nil?)
      return nil unless measurement.forecast
      forecast_measurement = measurement.for(utc_time)
      return nil unless forecast_measurement
      self.forecasted_wet_by_icon?(forecast_measurement) ||
        self.forecasted_wet_by_pop?(forecast_measurement, threshold)
    end

    # cookie cutter answer
    def self.forecasted_wet_by_pop?(forecast_measurement, threshold=50)
      raise ArgumentError unless forecast_measurement.is_a?(Barometer::ForecastMeasurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless forecast_measurement.pop?
      forecast_measurement.pop.to_f >= threshold.to_f
    end

    def self.currently_wet_by_icon?(current_measurement)
      raise ArgumentError unless current_measurement.is_a?(Barometer::CurrentMeasurement)
      return nil unless self.wet_icon_codes
      return nil unless current_measurement.icon?
      current_measurement.icon.is_a?(String) ?
        self.wet_icon_codes.include?(current_measurement.icon.to_s.downcase) :
        self.wet_icon_codes.include?(current_measurement.icon)
    end
    
    def self.forecasted_wet_by_icon?(forecast_measurement)
      raise ArgumentError unless forecast_measurement.is_a?(Barometer::ForecastMeasurement)
      return nil unless self.wet_icon_codes
      return nil unless forecast_measurement.icon?
      forecast_measurement.icon.is_a?(String) ?
        self.wet_icon_codes.include?(forecast_measurement.icon.to_s.downcase) :
        self.wet_icon_codes.include?(forecast_measurement.icon)
    end

    # this returns an array of codes that indicate "wet"
    def self.wet_icon_codes; nil; end

  end
  
end  
  
  # def key_name
  #   # what variables holds the api key?
  # end