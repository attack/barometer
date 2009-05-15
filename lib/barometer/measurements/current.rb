module Barometer
  #
  # Current Measurement
  # a data class for current weather conditions
  #
  # This is basically a data holding class for the current weather
  # conditions.
  #
  class Measurement::Current < Measurement::Common
    
    attr_reader :current_at, :updated_at
    attr_reader :temperature, :dew_point, :heat_index, :wind_chill
    attr_reader :pressure, :visibility
    
    # accessors (with input checking)
    #
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
    
    def pressure=(pressure)
      raise ArgumentError unless pressure.is_a?(Data::Pressure)
      @pressure = pressure
    end
    
    def visibility=(visibility)
      raise ArgumentError unless visibility.is_a?(Data::Distance)
      @visibility = visibility
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
    # answer simple questions
    #
    
    def wet?(wet_icons=nil, humidity_threshold=99)
      result = nil
      result ||= super(wet_icons, humidity_threshold) if (icon? || humidity?)
      result ||= _wet_by_dewpoint? if (dew_point? && temperature?)
      result
    end
    
    private
    
    def _wet_by_dewpoint?
      return nil unless dew_point? && temperature?
      temperature.to_f(metric?) <=  dew_point.to_f(metric?)
    end
    
  end
end