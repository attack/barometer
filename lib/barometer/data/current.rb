module Barometer
  #
  # Current Measurement
  # a data class for current weather conditions
  #
  # This is basically a data holding class for the current weather
  # conditions.
  #
  class CurrentMeasurement
    
    attr_reader :time, :humidity, :icon
    attr_reader :temperature, :dew_point, :heat_index, :wind_chill
    attr_reader :wind, :pressure, :visibility
    
    def time=(time)
      raise ArgumentError unless time.is_a?(Time)
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
    
  end
end