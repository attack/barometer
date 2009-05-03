module Barometer
  
  class Weather
    
    # hash of measurements indexed by :source
    attr_accessor :measurements
    
    def initialize
      @measurements = []
    end
    
    # the default source is the first source/measurement that we
    # have successful results for
    def default
      return nil unless self.sources
      self.source(self.sources.first)
    end
    
    # find the measurement for the given source, if it exists
    def source(source)
      raise ArgumentError unless (source.is_a?(String) || source.is_a?(Symbol))
      @measurements.each do |measurement|
        return measurement if measurement.source == source.to_sym
      end
      nil
    end
    
    # list successful sources
    def sources
      @measurements.collect {|m| m.source.to_sym if m.success?}.compact
    end
    
    #
    # Quick access methods
    #
    
    def current; (default = self.default) ? default.current : nil; end
    def forecast; (default = self.default) ? default.forecast : nil; end
    def now; self.current; end
    
    def today
      default = self.default
      default && default.forecast ? default.forecast[0] : nil
    end
    
    def tomorrow
      default = self.default
      default && default.forecast ? default.forecast[1] : nil
    end
    
    def for(query)
      default = self.default
      default && default.forecast ? default.for(query) : nil
    end
    
    #
    # helper methods
    #
    # these are handy methods that can average values for successful weather
    # sources, or answer a simple question (ie: weather.windy?)
    #
    
    #
    # averages
    #
    
    # TODO: not tested (except via averages)
    def metric?
      self.default ? self.default.metric? : true
    end
    
    # TODO: not tested (except via averages)
    # this assumes calculating for current, and that "to_f" for a value
    # will return the value needed
    # value_name = the name of the value we are averaging
    def current_average(value_name)
      values = []
      @measurements.each do |measurement|
        values << measurement.current.send(value_name).to_f if measurement.success?
      end
      return nil unless values && values.size > 0
      values.inject(0.0) { |sum,v| sum += v } / values.size
    end
    
    # TODO: not tested (except via averages)
    def average(value_name, do_average=true, class_name=nil)
      if class_name
        if do_average
          avg = Barometer.const_get(class_name).new(self.metric?)
          avg << self.current_average(value_name)
        else
          avg = self.now.send(value_name)
        end
      else
        avg = (do_average ? self.current_average(value_name) : self.now.send(value_name))
      end
      avg
    end
      
    # average of all values
    def humidity(do_average=true); average("humidity",do_average); end
    def temperature(do_average=true); average("temperature",do_average,"Temperature"); end
    def wind(do_average=true); average("wind",do_average,"Speed"); end
    def pressure(do_average=true); average("pressure",do_average,"Pressure"); end
    def dew_point(do_average=true); average("dew_point",do_average,"Temperature"); end
    def heat_index(do_average=true); average("heat_index",do_average,"Temperature"); end
    def wind_chill(do_average=true); average("wind_chill",do_average,"Temperature"); end
    def visibility(do_average=true); average("visibility",do_average,"Distance"); end
    
    #
    # quick access methods
    #
    
    # what is the current local time and date?
    # def time
    # end
    
    # def icon
    #   self.current.icon
    # end
    
    #
    # simple questions
    # pass the question on to each successful measurement until we get an answer
    #
    
    def windy?(threshold=10, utc_time=Time.now.utc)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless utc_time.is_a?(Time)
      
      is_windy = nil
      @measurements.each do |measurement|
        if measurement.success?
          is_windy = measurement.windy?(threshold, utc_time)
          return is_windy if !is_windy.nil?
        end
      end
      is_windy
    end

    def wet?(threshold=50, utc_time=Time.now.utc)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless utc_time.is_a?(Time)
      
      is_wet = nil
      @measurements.each do |measurement|
        if measurement.success?
          is_wet = measurement.wet?(threshold, utc_time)
          return is_wet if !is_wet.nil?
        end
      end
      is_wet
    end

    def day?(utc_time=Time.now.utc)
      raise ArgumentError unless utc_time.is_a?(Time)
      
      is_day = nil
      @measurements.each do |measurement|
        if measurement.success?
          is_day = measurement.day?(utc_time)
          return is_day if !is_day.nil?
        end
      end
      is_day
    end

    def night?(utc_time=Time.now.utc)
      raise ArgumentError unless utc_time.is_a?(Time)
      is_day = self.day?(utc_time)
      is_day.nil? ? nil : !is_day
    end

    def sunny?(utc_time=Time.now.utc)
      raise ArgumentError unless utc_time.is_a?(Time)
      
      is_sunny = nil
      @measurements.each do |measurement|
        if measurement.success?
          return false if self.day?(utc_time) == false
          is_sunny = measurement.sunny?(utc_time)
          return is_sunny if !is_sunny.nil?
        end
      end
      is_sunny
    end

  end
  
end