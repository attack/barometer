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
    # Some weather services require multiple api calls to get current
    # weather and future (forecasted) weather.  In an attempt to reduce
    # unneeded api calls (re: expensive), determine what data we are acutally
    # interested in and only get that
    #
    def self.measure(query, time=nil, metric=true)
      raise ArgumentError unless query.is_a?(Barometer::Query)
      raise ArgumentError unless (!time || time.is_a?(Time))
      # TODO: this next line has no test
      return nil unless self.meets_requirements?(query)
      
      # configurable paramter
      seconds_in_future_but_still_current = (60 * 10)

      now = Time.now
      current = false
      future = false
      today = false
      if time
        current = true if (time - now) <= seconds_in_future_but_still_current
      end
      unless !time || current
        future = true if time > now
      end
      unless !time || current
        today = true if (now.day == time.day) && (now.month == time.month) &&
                        (now.year == time.year)
      end
      
      preferred_query = query.convert!(self.accepted_formats)
      measurement = Barometer::Measurement.new
      if time && current
        # only get the current weather
        measurement = self.measure_current(measurement, preferred_query, metric)
      elsif time && future && today
        # the future time is actually still during the current
        # day.  we will need a mix of the forecasted data and
        # the current data
        measurement = self.measure_all(measurement, preferred_query, metric)
      elsif time && future && !today
        # only need to get the future weather
        measurement = self.measure_forecast(measurement, preferred_query, metric)
      else
        # time not defined, get all weather data
        measurement = self.measure_all(measurement, preferred_query, metric)
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
    def self.measure_all(measurement=nil, query=nil, metric=true)
      raise NotImplementedError
    end

    # STUB: define this method to measure the current weather
    def self.measure_current(measurement=nil, query=nil, metric=true)
      raise NotImplementedError
    end

    # STUB: define this method to measure the future weather
    def self.measure_forecast(measurement=nil, query=nil, metric=true)
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