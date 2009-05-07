require 'date'
module Barometer
  #
  # Night Measurement
  # a data class for forecasted night weather conditions
  #
  # This is basically a data holding class for the forecasted night 
  # weather conditions.
  #
  class Data::NightMeasurement
    
    attr_reader :date, :icon, :condition
    attr_reader :pop, :wind, :humidity
    
    # accessors (with input checking)
    #
    def date=(date)
      raise ArgumentError unless date.is_a?(Date)
      @date = date
    end
    
    def icon=(icon)
      raise ArgumentError unless icon.is_a?(String)
      @icon = icon
    end
    
    def condition=(condition)
      raise ArgumentError unless condition.is_a?(String)
      @condition = condition
    end
    
    def pop=(pop)
      raise ArgumentError unless pop.is_a?(Fixnum)
      @pop = pop
    end
    
    def wind=(wind)
      raise ArgumentError unless wind.is_a?(Data::Speed)
      @wind = wind
    end
    
    def humidity=(humidity)
      raise ArgumentError unless humidity.is_a?(Fixnum)
      @humidity = humidity
    end
    
    def sun=(sun)
      raise ArgumentError unless sun.is_a?(Data::Sun)
      @sun = sun
    end
    
    #
    # helpers
    #
    
    # creates "?" helpers for all attributes (which maps to nil?)
    #
    def method_missing(method,*args)
      # if the method ends in ?, then strip it off and see if we
      # respond to the method without the ?
      if (call_method = method.to_s.chomp!("?")) && respond_to?(call_method)
        return send(call_method).nil? ? false : true
      else
        super(method,*args)
      end
    end
    
  end
end