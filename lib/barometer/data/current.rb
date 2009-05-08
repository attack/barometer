module Barometer
  #
  # Current Measurement
  # a data class for current weather conditions
  #
  # This is basically a data holding class for the current weather
  # conditions.
  #
  class Data::CurrentMeasurement
    
    attr_reader :current_at, :updated_at
    attr_reader :humidity, :icon, :condition
    attr_reader :temperature, :dew_point, :heat_index, :wind_chill
    attr_reader :wind, :pressure, :visibility, :sun
    
    # accessors (with input checking)
    #
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
      raise ArgumentError unless temperature.is_a?(Data::Temperature)
      @temperature = temperature
    end
    
    def dew_point=(dew_point)
      raise ArgumentError unless dew_point.is_a?(Data::Temperature)
      @dew_point = dew_point
    end
    
    def heat_index=(heat_index)
      raise ArgumentError unless heat_index.is_a?(Data::Temperature)
      @heat_index = heat_index
    end
    
    def wind_chill=(wind_chill)
      raise ArgumentError unless wind_chill.is_a?(Data::Temperature)
      @wind_chill = wind_chill
    end
    
    def wind=(wind)
      raise ArgumentError unless wind.is_a?(Data::Speed)
      @wind = wind
    end
    
    def pressure=(pressure)
      raise ArgumentError unless pressure.is_a?(Data::Pressure)
      @pressure = pressure
    end
    
    def visibility=(visibility)
      raise ArgumentError unless visibility.is_a?(Data::Distance)
      @visibility = visibility
    end
    
    def sun=(sun)
      raise ArgumentError unless (sun.is_a?(Data::Sun) || sun.nil?)
      @sun = sun
    end
    
    def current_at=(current_at)
      raise ArgumentError unless (current_at.is_a?(Data::LocalTime) || current_at.is_a?(Data::LocalDateTime))
      @current_at = current_at
    end 
     
    def updated_at=(updated_at)
      raise ArgumentError unless (updated_at.is_a?(Data::LocalTime) || updated_at.is_a?(Data::LocalDateTime))
      @updated_at = updated_at
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