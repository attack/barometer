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
      raise ArgumentError unless time.class == Time
      @time = time
    end
    
    def humidity=(humidity)
      raise ArgumentError unless
        (humidity.class == Fixnum || humidity.class == Float)
      @humidity = humidity
    end
    
    def icon=(icon)
      raise ArgumentError unless icon.class == String
      @icon = icon
    end
    
    def temperature=(temperature)
      raise ArgumentError unless temperature.class == Barometer::Temperature
      @temperature = temperature
    end
    
    def dew_point=(dew_point)
      raise ArgumentError unless dew_point.class == Barometer::Temperature
      @dew_point = dew_point
    end
    
    def heat_index=(heat_index)
      raise ArgumentError unless heat_index.class == Barometer::Temperature
      @heat_index = heat_index
    end
    
    def wind_chill=(wind_chill)
      raise ArgumentError unless wind_chill.class == Barometer::Temperature
      @wind_chill = wind_chill
    end
    
    def wind=(wind)
      raise ArgumentError unless wind.class == Barometer::Speed
      @wind = wind
    end
    
    def pressure=(pressure)
      raise ArgumentError unless pressure.class == Barometer::Pressure
      @pressure = pressure
    end
    
    def visibility=(visibility)
      raise ArgumentError unless visibility.class == Barometer::Distance
      @visibility = visibility
    end
    
  end
end