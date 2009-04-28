module Barometer
  #
  # A simple Sun class
  # 
  # Used to store sunrise and sunset information
  #
  class Sun

    def initialize(rise=nil, set=nil)
      raise ArgumentError unless (rise.is_a?(Time) || rise.nil?)
      raise ArgumentError unless (set.is_a?(Time) || set.nil?)
      @rise_utc = rise
      @set_utc = set
    end

    def rise; @rise_utc; end
    def set; @set_utc; end
    
  end
end