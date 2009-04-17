module Barometer
  #
  # A simple Distance class
  # 
  # Think of this like the Integer class. Enhancement
  # is that you can create a number (in a certain unit), then
  # get that number back already converted to another unit.
  #
  # All comparison operations will be done in metric
  # 
  # NOTE: this currently only supports the scale of
  #       kilometers (km) and miles (m).  There is currently
  #       no way to scale to smaller units (eg km -> m -> mm)
  class Distance < Barometer::Units
    
    METRIC_UNITS = "km"
    IMPERIAL_UNITS = "m"
    
    attr_accessor :kilometers, :miles
    
    def initialize(metric=true)
      @kilometers = nil
      @miles = nil
      super(metric)
    end
    
    #
    # CONVERTERS
    #
    
    def self.km_to_m(km)
      return nil unless km && (km.is_a?(Integer) || km.is_a?(Float))
      km.to_f * 0.622
    end
    
    def self.m_to_km(m)
      return nil unless m && (m.is_a?(Integer) || m.is_a?(Float))
      m.to_f * 1.609
    end
    
    #
    # ACCESSORS
    #
    
    # store kilometers
    def km=(km)
      return if !km || !(km.is_a?(Integer) || km.is_a?(Float))
      @kilometers = km.to_f
      self.update_miles(km.to_f)
    end
    
    # store miles
    def m=(m)
      return if !m || !(m.is_a?(Integer) || m.is_a?(Float))
      @miles = m.to_f
      self.update_kilometers(m.to_f)
    end
    
    # return the stored kilometers or convert from miles
    def km(as_integer=true)
      km = (@kilometers || Distance.m_to_km(@miles))
      km ? (as_integer ? km.to_i : (100*km).round/100.0) : nil
    end
    
    # return the stored miles or convert from kilometers
    def m(as_integer=true)
      m = (@miles || Distance.km_to_m(@kilometers))
      m ? (as_integer ? m.to_i : (100*m).round/100.0) : nil
    end
    
    #
    # OPERATORS
    #
    
    def <=>(other)
      self.km <=> other.km
    end
    
    def <(other)
      self.km < other.km
    end
    
    def >(other)
      self.km > other.km
    end
    
    def ==(other)
      self.km == other.km
    end
    
    def <=(other)
      self.km <= other.km
    end
      
    def >=(other)
      self.km >= other.km
    end
    
    #
    # HELPERS
    #
    
    # will just return the value (no units)
    def to_i(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.km : self.m
    end
    
    # will just return the value (no units) with more precision
    def to_f(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.km(false) : self.m(false)
    end
    
    # will return the value with units
    def to_s(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? "#{self.km} #{METRIC_UNITS}" : "#{self.m} #{IMPERIAL_UNITS}"
    end
    
    # will just return the units (no value)
    def units(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? METRIC_UNITS : IMPERIAL_UNITS
    end
    
    # when we set miles, it is possible the a non-equivalent value of
    # kilometers remains.  if so, clear it.
    def update_kilometers(m)
      return unless @kilometers
      difference = Distance.m_to_km(m.to_f) - @kilometers
      # only clear kilometers if the stored kilometers is off be more then 1 unit
      # then the conversion of miles
      @kilometers = nil unless difference.abs <= 1.0
    end
    
    # when we set kilometers, it is possible the a non-equivalent value of
    # miles remains.  if so, clear it.
    def update_miles(km)
      return unless @miles
      difference = Distance.km_to_m(km.to_f) - @miles
      # only clear miles if the stored miles is off be more then 1 unit
      # then the conversion of kilometers
      @miles = nil unless difference.abs <= 1.0
    end
    
  end
end