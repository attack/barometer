require 'date'
module Barometer
  #
  # Forecast Measurement
  # a data class for forecasted weather conditions
  #
  # This is basically a data holding class for the forecasted weather
  # conditions.
  #
  class Measurement::Forecast < Measurement::Common
    
    attr_reader :date
    attr_reader :low, :high, :pop, :night
    
    # accessors (with input checking)
    #
    def date=(date)
      raise ArgumentError unless date.is_a?(Date)
      @date = date
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
    
    def night=(night)
      raise ArgumentError unless night.is_a?(Measurement::ForecastNight)
      @night = night
    end
    
    #
    # answer simple questions
    #
    
    def wet?(wet_icons=nil, pop_threshold=50, humidity_threshold=99)
      result = nil
      result ||= _wet_by_pop?(pop_threshold) if pop?
      result ||= super(wet_icons, humidity_threshold) if (icon? || humidity?)
      result
    end
    
    private
    
    def _wet_by_pop?(threshold=50)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless pop?
      pop.to_f >= threshold.to_f
    end
    
  end
end