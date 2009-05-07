require 'date'
module Barometer
  #
  # Forecast Measurement
  # a data class for forecasted weather conditions
  #
  # This is basically a data holding class for the forecasted weather
  # conditions.
  #
  class Data::ForecastMeasurement
    
    attr_reader :date, :icon, :condition
    attr_reader :low, :high, :pop, :wind, :humidity, :sun, :night
    
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
    
    def high=(high)
      raise ArgumentError unless high.is_a?(Data::Temperature)
      @high = high
    end
    
    def low=(low)
      raise ArgumentError unless low.is_a?(Data::Temperature)
      @low = low
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
    
    def night=(night)
      raise ArgumentError unless night.is_a?(Data::NightMeasurement)
      @night = night
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