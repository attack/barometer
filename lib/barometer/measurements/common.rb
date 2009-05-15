module Barometer
  #
  # Common Measurement
  #
  # Code common to both Current and Forecast Measurements
  #
  class Measurement::Common
    
    attr_reader :humidity, :icon, :condition
    attr_reader :wind, :sun
    attr_accessor :metric
    
    def initialize(metric=true)
      @metric = metric
    end
    
    def metric?; metric; end
    
    # accessors (with input checking)
    #
    def humidity=(humidity)
      raise ArgumentError unless
        (humidity.is_a?(Fixnum) || humidity.is_a?(Float))
      @humidity = humidity
    end
    
    def icon=(icon)
      raise ArgumentError unless icon.is_a?(String)
      @icon = icon
    end
    
    def condition=(condition)
      raise ArgumentError unless condition.is_a?(String)
      @condition = condition
    end
    
    def wind=(wind)
      raise ArgumentError unless wind.is_a?(Data::Speed)
      @wind = wind
    end
    
    def sun=(sun)
      raise ArgumentError unless (sun.is_a?(Data::Sun) || sun.nil?)
      @sun = sun
    end
    
    #
    # helpers
    #
    
    # creates "?" helpers for all attributes (which maps to nil?)
    #
    def method_missing(method,*args)
      # if the method ends in ?, then strip it off and see if we
      # respond to the method without the ?
      if (call_method = method.to_s.chomp!("?")) && respond_to?(call_method)
        return send(call_method).nil? ? false : true
      else
        super(method,*args)
      end
    end
    
    #
    # answer simple questions
    #
    
    def windy?(threshold=10)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless wind?
      wind.to_f(metric?) >= threshold.to_f
    end
    
    def day?(time)
      return nil unless time && sun?
      sun.after_rise?(time) && sun.before_set?(time)
    end
    
    def wet?(wet_icons=nil, humidity_threshold=99)
      result = nil
      result ||= _wet_by_icon?(wet_icons) if icon?
      result ||= _wet_by_humidity?(humidity_threshold) if humidity?
      result
    end
    
    def sunny?(time, sunny_icons=nil)
      return nil unless time
      is_day = day?(time)
      return nil if is_day.nil?
      is_day && _sunny_by_icon?(sunny_icons)
    end
    
    private
    
    def _wet_by_humidity?(threshold=99)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless humidity?
      humidity.to_f >= threshold.to_f
    end
    
    def _wet_by_icon?(wet_icons=nil)
      raise ArgumentError unless (wet_icons.nil? || wet_icons.is_a?(Array))
      return nil unless (icon? && wet_icons)
      wet_icons.include?(icon.to_s.downcase)
    end
    
    def _sunny_by_icon?(sunny_icons=nil)
      raise ArgumentError unless (sunny_icons.nil? || sunny_icons.is_a?(Array))
      return nil unless (icon? && sunny_icons)
      sunny_icons.include?(icon.to_s.downcase)
    end
    
  end
end
