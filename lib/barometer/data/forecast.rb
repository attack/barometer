require 'date'
module Barometer
  #
  # Forecast Measurement
  # a data class for forecasted weather conditions
  #
  # This is basically a data holding class for the forecasted weather
  # conditions.
  #
  class ForecastMeasurement
    
    attr_reader :date, :icon, :condition
    attr_reader :low, :high, :pop
    
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
      raise ArgumentError unless high.is_a?(Barometer::Temperature)
      @high = high
    end
    
    def low=(low)
      raise ArgumentError unless low.is_a?(Barometer::Temperature)
      @low = low
    end
    
    def pop=(pop)
      raise ArgumentError unless pop.is_a?(Fixnum)
      @pop = pop
    end
    
    #
    # helpers
    #
    
    # creates "?" helpers for all attributes (which maps to nil?)
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