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
    
    def current
      (default = self.default) ? default.current : nil
    end
    
    def forecast
      (default = self.default) ? default.forecast : nil
    end

    def now
      self.current
    end
    
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
    
    # average of all humidity values
    # def humidity
    # end
    # 
    # # average of all temperature values
    # def temperature
    # end
    # 
    # # average of all wind speed values
    # def wind
    # end
    # 
    # # average of all pressure values
    # def pressure
    # end
    # 
    # # average of all dew_point values
    # def dew_point
    # end
    # 
    # # average of all heat_index values
    # def heat_index
    # end
    # 
    # # average of all wind_chill values
    # def wind_chill
    # end
    # 
    # # average of all visibility values
    # def visibility
    # end
    
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
    #
    
    # pass the question on to each successful measurement until we get an answer
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

    # def wet?(threshold=50)
    # end
    # 
    # def sunny?
    # end
    # 
    # def day?
    # end
    # 
    # def night?
    #   !self.day?
    # end
    
  end
  
end