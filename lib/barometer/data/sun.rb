module Barometer
  #
  # A simple Sun class
  # 
  # Used to store sunrise and sunset information
  #
  class Data::Sun
    
    def initialize(rise=nil, set=nil)
      raise ArgumentError unless (rise.is_a?(Data::LocalTime) || rise.nil?)
      raise ArgumentError unless (set.is_a?(Data::LocalTime) || set.nil?)
      @rise_utc = rise
      @set_utc = set
    end

    def rise; @rise_utc; end
    def set; @set_utc; end
    
    # useful for incrementing the sunrise and sunset times by exactly
    # N days ... used when using the same sun data for other days
    # def self.add_days!(sun, n=1)
    #   raise ArgumentError unless sun.is_a?(Data::Sun)
    #   raise ArgumentError unless n.is_a?(Fixnum)
    #   seconds_to_add = 60*60*24*n
    #   rise_utc = sun.rise + seconds_to_add
    #   set_utc = sun.set + seconds_to_add
    #   self.new(rise_utc, set_utc)
    # end
    
    def nil?
      (@rise_utc || @set_utc) ? false : true
    end
    
  end
end