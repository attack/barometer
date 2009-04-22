module Barometer
  #
  # A simple Pressure class
  # 
  # Think of this like the Integer class. Enhancement
  # is that you can create a number (in a certain unit), then
  # get that number back already converted to another unit.
  #
  # All comparison operations will be done in metric
  #
  # NOTE: the metric units for pressure aren't commonly used, except
  #       that this class was designed for storing weather data,
  #       and it seems that it is more common in this case
  #
  class Pressure < Barometer::Units
    
    METRIC_UNITS = "mb"
    IMPERIAL_UNITS = "in"
    
    attr_accessor :millibars, :inches
    
    def initialize(metric=true)
      @millibars = nil
      @inches = nil
      super(metric)
    end
    
    #
    # CONVERTERS
    #
    
    def self.mb_to_in(mb)
      return nil unless mb && (mb.is_a?(Integer) || mb.is_a?(Float))
      mb.to_f * 0.02953
    end
    
    def self.in_to_mb(inches)
      return nil unless inches &&
        (inches.is_a?(Integer) || inches.is_a?(Float))
      inches.to_f * 33.8639
    end
    
    #
    # ACCESSORS
    #
    
    # store millibars
    def mb=(mb)
      return if !mb || !(mb.is_a?(Integer) || mb.is_a?(Float))
      @millibars = mb.to_f
      self.update_inches(mb.to_f)
    end
    
    # store inches
    def in=(inches)
      return if !inches || !(inches.is_a?(Integer) || inches.is_a?(Float))
      @inches = inches.to_f
      self.update_millibars(inches.to_f)
    end
    
    # return the stored millibars or convert from inches
    def mb(as_integer=true)
      mb = (@millibars || Pressure.in_to_mb(@inches))
      mb ? (as_integer ? mb.to_i : (100*mb).round/100.0) : nil
    end
    
    # return the stored inches or convert from millibars
    def in(as_integer=true)
      inches = (@inches || Pressure.mb_to_in(@millibars))
      inches ? (as_integer ? inches.to_i : (100*inches).round/100.0) : nil
    end
    
    #
    # OPERATORS
    #
    
    def <=>(other)
      self.mb <=> other.mb
    end
    
    #
    # HELPERS
    #
    
    # will just return the value (no units)
    def to_i(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.mb : self.in
    end
    
    # will just return the value (no units) with more precision
    def to_f(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.mb(false) : self.in(false)
    end
    
    # will return the value with units
    def to_s(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? "#{self.mb} #{METRIC_UNITS}" : "#{self.in} #{IMPERIAL_UNITS}"
    end
    
    # will just return the units (no value)
    def units(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? METRIC_UNITS : IMPERIAL_UNITS
    end
    
    # when we set inches, it is possible the a non-equivalent value of
    # millibars remains.  if so, clear it.
    def update_millibars(inches)
      return unless @millibars
      difference = Pressure.in_to_mb(inches.to_f) - @millibars
      # only clear millibars if the stored millibars is off be more then 1 unit
      # then the conversion of inches
      @millibars = nil unless difference.abs <= 1.0
    end
    
    # when we set millibars, it is possible the a non-equivalent value of
    # inches remains.  if so, clear it.
    def update_inches(mb)
      return unless @inches
      difference = Pressure.mb_to_in(mb.to_f) - @inches
      # only clear inches if the stored inches is off be more then 1 unit
      # then the conversion of millibars
      @inches = nil unless difference.abs <= 1.0
    end
    
  end
end