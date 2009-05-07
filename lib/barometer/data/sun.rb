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
    
  end
end