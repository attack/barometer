module Barometer
  #
  # A simple Speed class
  # 
  # Think of this like the Integer class. Enhancement
  # is that you can create a number (in a certain unit), then
  # get that number back already converted to another unit.
  #
  # Speed is a vector, thus it has a perticular direction, although
  # the direction is independent of the units
  #
  # All comparison operations will be done in metric
  # 
  # NOTE: this currently only supports the scale of
  #       kilometers (km) and miles (m) per hour.  There is currently
  #       no way to scale to smaller units (eg km -> m -> mm)
  class Data::Speed < Data::Units
    
    METRIC_UNITS = "kph"
    IMPERIAL_UNITS = "mph"
    
    attr_accessor :kilometers, :miles
    attr_accessor :degrees, :direction
    
    def initialize(metric=true)
      @kilometers = nil
      @miles = nil
      @degrees = nil
      @direction = nil
      super(metric)
    end
    
    def metric_default=(value); self.kph = value; end
    def imperial_default=(value); self.mph = value; end
    
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
    
    # store kilometers per hour
    def kph=(kph)
      return if !kph || !(kph.is_a?(Integer) || kph.is_a?(Float))
      @kilometers = kph.to_f
      self.update_miles(kph.to_f)
    end
    
    # store miles per hour
    def mph=(mph)
      return if !mph || !(mph.is_a?(Integer) || mph.is_a?(Float))
      @miles = mph.to_f
      self.update_kilometers(mph.to_f)
    end
    
    def direction=(direction)
      return if !direction || !direction.is_a?(String)
      @direction = direction
    end
    
    def degrees=(degrees)
      return if !degrees || !(degrees.is_a?(Integer) || degrees.is_a?(Float))
      @degrees = degrees
    end
    
    # return the stored kilometers or convert from miles
    def kph(as_integer=true)
      km = (@kilometers || Data::Speed.m_to_km(@miles))
      km ? (as_integer ? km.to_i : (100*km).round/100.0) : nil
    end
    
    # return the stored miles or convert from kilometers
    def mph(as_integer=true)
      m = (@miles || Data::Speed.km_to_m(@kilometers))
      m ? (as_integer ? m.to_i : (100*m).round/100.0) : nil
    end
    
    #
    # OPERATORS
    #
    
    def <=>(other)
      self.kph <=> other.kph
    end
    
    #
    # HELPERS
    #
    
    # will just return the value (no units)
    def to_i(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.kph : self.mph
    end
    
    # will just return the value (no units) with more precision
    def to_f(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.kph(false) : self.mph(false)
    end
    
    # will return the value with units
    def to_s(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? "#{self.kph} #{METRIC_UNITS}" : "#{self.mph} #{IMPERIAL_UNITS}"
    end
    
    # will just return the units (no value)
    def units(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? METRIC_UNITS : IMPERIAL_UNITS
    end
    
    # when we set miles, it is possible the a non-equivalent value of
    # kilometers remains.  if so, clear it.
    def update_kilometers(m)
      return unless @kilometers
      difference = Data::Speed.m_to_km(m.to_f) - @kilometers
      # only clear kilometers if the stored kilometers is off be more then 1 unit
      # then the conversion of miles
      @kilometers = nil unless difference.abs <= 1.0
    end
    
    # when we set kilometers, it is possible the a non-equivalent value of
    # miles remains.  if so, clear it.
    def update_miles(km)
      return unless @miles
      difference = Data::Speed.km_to_m(km.to_f) - @miles
      # only clear miles if the stored miles is off be more then 1 unit
      # then the conversion of kilometers
      @miles = nil unless difference.abs <= 1.0
    end
    
    def nil?
      (@kilometers || @miles) ? false : true
    end
    
  end
end