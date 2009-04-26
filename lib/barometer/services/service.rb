require 'rubygems'
require 'httparty'

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
      
      measurement = Barometer::Measurement.new
      measurement.source = self.source_name
      if self.meets_requirements?(query)
        preferred_query = query.convert!(self.accepted_formats)
        measurement = self._measure(measurement, preferred_query, metric) if preferred_query
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

    # STUB: define this method to actually retireve the current weather
    def self.get_current
      raise NotImplementedError
    end

    # STUB: define this method to actually retireve the forecast weather
    def self.get_forecast
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
    
  end
  
end  
  
 # def self.
  
  # def supported_countries
  #   # all, or
  #   
  #   # list
  #   # - US
  #   # - CA
  # end
  # 
  # def supoorted_inputs
  #   
  #   # this list is also an order of preference
  #   
  #   # zip_code
  #   # postal_code
  #   # coordinates
  #   # location_name
  #   # IACO
  # end
  # 
  # def requires_key
  #   return false
  # end
  # 
  # def key_name
  #   # what variables holds the api key?
  # end
  # 
  # def retrieve
  #   # may require multiple queries
  #   self.retrieve_current
  #   self.retrieve_forecast
  #   self.retrieve_all
  # end
  # 
  # def retrieve_current
  # end
  # 
  # def retrieve_forecast
  # end
  # 
  # def retrieve_all
  # end
  # 
  # def temperature
  # end
  # def location
  # end
  # def station
  # end
  # def current
  # end
  # def forecast
  # end
  # def zone
  # end