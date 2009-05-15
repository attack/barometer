require 'date'
module Barometer
  #
  # Night Measurement
  # a data class for forecasted night weather conditions
  #
  # This is basically a data holding class for the forecasted night 
  # weather conditions.
  #
  class Measurement::ForecastNight < Measurement::Common
    
    attr_reader :date, :pop
    
    # accessors (with input checking)
    #
    def date=(date)
      raise ArgumentError unless date.is_a?(Date)
      @date = date
    end
    
    def pop=(pop)
      raise ArgumentError unless pop.is_a?(Fixnum)
      @pop = pop
    end
    
  end
end