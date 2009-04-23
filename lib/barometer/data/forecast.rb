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
    
    attr_reader :date, :icon
    attr_reader :low, :high
    
    def date=(date)
      raise ArgumentError unless date.is_a?(Date)
      @date = date
    end
    
    def icon=(icon)
      raise ArgumentError unless icon.is_a?(String)
      @icon = icon
    end
    def high=(high)
      raise ArgumentError unless high.is_a?(Barometer::Temperature)
      @high = high
    end
    
    def low=(low)
      raise ArgumentError unless low.is_a?(Barometer::Temperature)
      @low = low
    end
    
  end
end