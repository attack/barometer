module Barometer
  #
  # Result Measurement
  # a data class for resulting weather conditions
  #
  # This is basically a data holding class for the resulting weather
  # conditions.
  #
  class Measurement::Result

    attr_reader :current_at, :updated_at
    attr_reader :valid_start_date, :valid_end_date, :date
    attr_reader :humidity, :icon, :condition
    attr_reader :temperature, :dew_point, :heat_index, :wind_chill
    attr_reader :low, :high, :pop
    attr_reader :wind, :sun, :pressure, :visibility
    attr_accessor :metric, :description

    def initialize(metric=true); @metric = metric; end

    # accessors (with input checking)
    #
    def temperature=(temperature)
      raise ArgumentError unless temperature.is_a?(Data::Temperature)
      @temperature = temperature
    end

    def dew_point=(dew_point)
      raise ArgumentError unless dew_point.is_a?(Data::Temperature)
      @dew_point = dew_point
    end

    def heat_index=(heat_index)
      raise ArgumentError unless heat_index.is_a?(Data::Temperature)
      @heat_index = heat_index
    end

    def wind_chill=(wind_chill)
      raise ArgumentError unless wind_chill.is_a?(Data::Temperature)
      @wind_chill = wind_chill
    end

    def pressure=(pressure)
      raise ArgumentError unless pressure.is_a?(Data::Pressure)
      @pressure = pressure
    end

    def visibility=(visibility)
      raise ArgumentError unless visibility.is_a?(Data::Distance)
      @visibility = visibility
    end

    def current_at=(current_at)
      raise ArgumentError unless (current_at.is_a?(Data::LocalTime) || current_at.is_a?(Data::LocalDateTime))
      @current_at = current_at
    end

    def updated_at=(updated_at)
      raise ArgumentError unless (updated_at.is_a?(Data::LocalTime) || updated_at.is_a?(Data::LocalDateTime))
      @updated_at = updated_at
    end

    def date=(date)
      raise ArgumentError unless date.is_a?(Date)
      @date = date
      @valid_start_date = Data::LocalDateTime.new(date.year,date.month,date.day,0,0,0)
      @valid_end_date = Data::LocalDateTime.new(date.year,date.month,date.day,23,59,59)
    end

    def valid_start_date=(date)
      raise ArgumentError unless date.is_a?(Data::LocalDateTime)
      @valid_start_date = date
    end

    def valid_end_date=(date)
      raise ArgumentError unless date.is_a?(Data::LocalDateTime)
      @valid_end_date = date
    end

    def high=(high)
      raise ArgumentError unless high.is_a?(Data::Temperature)
      @high = high
    end

    def low=(low)
      raise ArgumentError unless low.is_a?(Data::Temperature)
      @low = low
    end

    def pop=(pop)
      raise ArgumentError unless pop.is_a?(Fixnum)
      @pop = pop
    end

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

    def sunny?(time, sunny_icons=nil)
      return nil unless time
      is_day = day?(time)
      return nil if is_day.nil?
      is_day && _sunny_by_icon?(sunny_icons)
    end

    def wet?(wet_icons=nil, pop_threshold=50, humidity_threshold=99)
      result = nil
      result ||= _wet_by_pop?(pop_threshold) if pop?
      result ||= _wet_by_icon?(wet_icons) if icon?
      result ||= _wet_by_humidity?(humidity_threshold) if humidity?
      result ||= _wet_by_dewpoint? if (dew_point? && temperature?)
      result
    end

    #
    # helpers
    #

    def metric?; metric; end

    def for_datetime?(datetime)
      raise ArgumentError unless datetime.is_a?(Data::LocalDateTime)
      datetime >= @valid_start_date && datetime <= @valid_end_date
    end

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

    private

    def _wet_by_dewpoint?
      return nil unless dew_point? && temperature?
      temperature.to_f(metric?) <=  dew_point.to_f(metric?)
    end

    def _wet_by_pop?(threshold=50)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      return nil unless pop?
      pop.to_f >= threshold.to_f
    end

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
