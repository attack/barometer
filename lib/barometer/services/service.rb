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
    
    #
    # Some weather services require multiple api calls to get current
    # weather and future (forecasted) weather.  In an attempt to reduce
    # unneeded api calls (re: expensive), determine what data we are acutally
    # interested in and only get that
    #
    def self.measure(query, time=nil, metric=true)
    #   # TODO: check that all api keys are present?
    #   # TODO: check if country supported?
    #   # return nil unless self.supports_country?(location.country_code)
      raise ArgumentError unless (query && query.is_a?(Barometer::Query))
    #   preffered_formats = self.accepted_formats
    #   query = location.convert_query!(preffered_formats)
    #
    #   measurement = nil
    #   if time && time.current?
    #     # only need to get the current weather
    #     measurement = self.measure_current(query, metric)
    #   elsif time && time.all?
    #     # we need all the weather data
    #     measurement = self.measure_all(query, metric)
    #   elsif time && time.future? && time.today?
    #     # the future time is actually still during the current
    #     # day.  we will need a mix of the forecasted data and
    #     # the current data
    #     measurement = self.measure_all(query, metric)
    #   elsif time && time.future? && !time.today?
    #     # only need to get the future weather
    #     measurement = self.measure_future(query, metric)
    #   else
    #     # time is not defined, default to getting all
    #     # the weather data
    #     measurement = self.measure_all(query, metric)
    #   end
    #   measurement
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
    def self.measure_all
      raise NotImplementedError
    end

    # STUB: define this method to measure the current weather
    def self.measure_current
      raise NotImplementedError
    end

    # STUB: define this method to measure the future weather
    def self.measure_future
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