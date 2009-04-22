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
    
    # def date=(date)
    #   raise ArgumentError unless date.class == Time::Date
    #   @date = date
    # end
    
    def icon=(icon)
      raise ArgumentError unless icon.class == String
      @icon = icon
    end
    def high=(high)
      raise ArgumentError unless high.class == Barometer::Temperature
      @high = high
    end
    
    def low=(low)
      raise ArgumentError unless low.class == Barometer::Temperature
      @low = low
    end
    
  end
end