module Barometer
  #
  # A simple Temperature class
  # 
  # Think of this like the Integer class. Enhancement
  # is that you can create a number (in a certain unit), then
  # get that number back already converted to another unit.
  #
  # All comparison operations will be done in the absolute
  # scale of Kelvin (K)
  #
  class Temperature < Barometer::Units
    
    METRIC_UNITS = "C"
    IMPERIAL_UNITS = "F"
    
    attr_accessor :celsius, :fahrenheit, :kelvin
    
    def initialize(metric=true)
      @celsius = nil
      @fahrenheit = nil
      @kelvin = nil
      super(metric)
    end
    
    def metric_default=(value); self.c = value; end
    def imperial_default=(value); self.f = value; end

    #
    # CONVERTERS
    #
    
    def self.c_to_k(c)
      return nil unless c && (c.is_a?(Integer) || c.is_a?(Float))
      273.15 + c.to_f
    end
    
    # Tf = (9/5)*Tc+32
    def self.c_to_f(c)
      return nil unless c && (c.is_a?(Integer) || c.is_a?(Float))
       ((9.0/5.0)*c.to_f)+32.0
    end
    
    # Tc = (5/9)*(Tf-32)
    def self.f_to_c(f)
      return nil unless f && (f.is_a?(Integer) || f.is_a?(Float))
      (5.0/9.0)*(f.to_f-32.0)
    end
    
    def self.f_to_k(f)
      return nil unless f && (f.is_a?(Integer) || f.is_a?(Float))
      c = self.f_to_c(f.to_f)
      self.c_to_k(c)
    end
    
    def self.k_to_c(k)
      return nil unless k && (k.is_a?(Integer) || k.is_a?(Float))
      k.to_f - 273.15
    end
    
    def self.k_to_f(k)
      return nil unless k && (k.is_a?(Integer) || k.is_a?(Float))
      c = self.k_to_c(k.to_f)
      self.c_to_f(c)
    end
    
    #
    # ACCESSORS
    #
    
    # store celsius and kelvin
    def c=(c)
      return if !c || !(c.is_a?(Integer) || c.is_a?(Float))
      @celsius = c.to_f
      @kelvin = Temperature.c_to_k(c.to_f)
      self.update_fahrenheit(c.to_f)
    end
    
    # store fahrenheit and kelvin
    def f=(f)
      return if !f || !(f.is_a?(Integer) || f.is_a?(Float))
      @fahrenheit = f.to_f
      @kelvin = Temperature.f_to_k(f.to_f)
      self.update_celsius(f.to_f)
    end
    
    # store kelvin, convert to all
    def k=(k)
      return if !k || !(k.is_a?(Integer) || k.is_a?(Float))
      @kelvin = k.to_f
      @celsius = Temperature.k_to_c(k.to_f)
      @fahrenheit = Temperature.k_to_f(k.to_f)
    end
    
    # return the stored celsius or convert from Kelvin
    def c(as_integer=true)
      c = (@celsius || Temperature.k_to_c(@kelvin))
      c ? (as_integer ? c.to_i : (100*c).round/100.0) : nil
    end
    
    # return the stored fahrenheit or convert from Kelvin
    def f(as_integer=true)
      f = (@fahrenheit || Temperature.k_to_f(@kelvin))
      f ? (as_integer ? f.to_i : (100*f).round/100.0) : nil
    end
    
    #
    # OPERATORS
    #
    
    def <=>(other)
      @kelvin <=> other.kelvin
    end
    
    #
    # HELPERS
    #
    
    # will just return the value (no units)
    def to_i(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.c : self.f
    end
    
    # will just return the value (no units) with more precision
    def to_f(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? self.c(false) : self.f(false)
    end
    
    # will return the value with units
    def to_s(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? "#{self.c} #{METRIC_UNITS}" : "#{self.f} #{IMPERIAL_UNITS}"
    end
    
    # will just return the units (no value)
    def units(metric=nil)
      (metric || (metric.nil? && self.metric?)) ? METRIC_UNITS : IMPERIAL_UNITS
    end
    
    # when we set fahrenheit, it is possible the a non-equivalent value of
    # celsius remains.  if so, clear it.
    def update_celsius(f)
      return unless @celsius
      difference = Temperature.f_to_c(f.to_f) - @celsius
      # only clear celsius if the stored celsius is off be more then 1 degree
      # then the conversion of fahrenheit
      @celsius = nil unless difference.abs <= 1.0
    end
    
    # when we set celsius, it is possible the a non-equivalent value of
    # fahrenheit remains.  if so, clear it.
    def update_fahrenheit(c)
      return unless @fahrenheit
      difference = Temperature.c_to_f(c.to_f) - @fahrenheit
      # only clear fahrenheit if the stored fahrenheit is off be more then 1 degree
      # then the conversion of celsius
      @fahrenheit = nil unless difference.abs <= 1.0
    end
    
    def nil?
      (@celsius || @fahrenheit || @kelvin) ? false : true
    end
    
  end
end