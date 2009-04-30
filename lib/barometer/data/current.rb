module Barometer
  #
  # Current Measurement
  # a data class for current weather conditions
  #
  # This is basically a data holding class for the current weather
  # conditions.
  #
  class CurrentMeasurement
    
    attr_accessor :time, :local_time
    attr_reader :humidity, :icon, :condition
    attr_reader :temperature, :dew_point, :heat_index, :wind_chill
    attr_reader :wind, :pressure, :visibility, :sun
    
    def time=(time)
      #raise ArgumentError unless time.is_a?(Time)
      @time = time
    end
    
    def humidity=(humidity)
      raise ArgumentError unless
        (humidity.is_a?(Fixnum) || humidity.is_a?(Float))
      @humidity = humidity
    end
    
    def icon=(icon)
      raise ArgumentError unless icon.is_a?(String)
      @icon = icon
    end
    
    def condition=(condition)
      raise ArgumentError unless condition.is_a?(String)
      @condition = condition
    end
    
    def temperature=(temperature)
      raise ArgumentError unless temperature.is_a?(Barometer::Temperature)
      @temperature = temperature
    end
    
    def dew_point=(dew_point)
      raise ArgumentError unless dew_point.is_a?(Barometer::Temperature)
      @dew_point = dew_point
    end
    
    def heat_index=(heat_index)
      raise ArgumentError unless heat_index.is_a?(Barometer::Temperature)
      @heat_index = heat_index
    end
    
    def wind_chill=(wind_chill)
      raise ArgumentError unless wind_chill.is_a?(Barometer::Temperature)
      @wind_chill = wind_chill
    end
    
    def wind=(wind)
      raise ArgumentError unless wind.is_a?(Barometer::Speed)
      @wind = wind
    end
    
    def pressure=(pressure)
      raise ArgumentError unless pressure.is_a?(Barometer::Pressure)
      @pressure = pressure
    end
    
    def visibility=(visibility)
      raise ArgumentError unless visibility.is_a?(Barometer::Distance)
      @visibility = visibility
    end
    
    def sun=(sun)
      raise ArgumentError unless sun.is_a?(Barometer::Sun)
      @sun = sun
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