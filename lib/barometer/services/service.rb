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
    
    def self.windy?(measurement, threshold=10, utc_time=nil)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (utc_time.is_a?(Time) || utc_time.nil?)

      return measurement.current?(utc_time) ?
        self.currently_windy?(measurement, threshold) :
        self.forecasted_windy?(measurement, threshold, utc_time)
    end
    
    # if a service doesn't support obtaining the wind value, it will be ignored
    def self.currently_windy?(measurement, threshold=10)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil if (!measurement.current || !measurement.current.wind || !measurement.current.wind.kph)
      return measurement.metric? ?
        measurement.current.wind.kph.to_f >= threshold.to_f :
        measurement.current.wind.mph.to_f >= threshold.to_f
    end

    # no driver can currently answer this question, so it doesn't have any code
    def self.forecasted_windy?(measurement, threshold, utc_time); nil; end
    
  end
  
end  
  
  # def key_name
  #   # what variables holds the api key?
  # end