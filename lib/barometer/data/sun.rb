module Barometer
  #
  # A simple Sun class
  # 
  # Used to store sunrise and sunset information
  #
  class Data::Sun
    
    attr_reader :rise, :set
    
    def initialize(rise=nil, set=nil)
      raise ArgumentError unless (rise.is_a?(Data::LocalTime) || rise.nil?)
      raise ArgumentError unless (set.is_a?(Data::LocalTime) || set.nil?)
      @rise = rise
      @set = set
    end

    def nil?
      (@rise || @set) ? false : true
    end
   
    def after_rise?(time)
      raise ArgumentError unless time.is_a?(Data::LocalTime)
      time >= @rise
    end
    
    def before_set?(time)
      raise ArgumentError unless time.is_a?(Data::LocalTime)
      time <= @set
    end
   
  end
end