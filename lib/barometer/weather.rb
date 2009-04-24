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
    
    def today
      default = self.default
      default && default.forecast ? default.forecast[0] : nil
    end
    
    def tommorrow
      default = self.default
      default && default.forecast ? default.forecast[1] : nil
    end
    
    def for(query)
      default = self.default
      default && default.forecast ? default.for(query) : nil
    end
    
    # TODO
    # these could be used for quick access to the default values, or averaging
    # of all values ... need a way to weight values
    
    # def time
    #   self.current.time
    # end
    # def humidity
    #   self.current.humidity
    # end
    # def icon
    #   self.current.icon
    # end
    # # NOTE: could average all current temperatures (if more then one)
    # def temperature
    #   self.current.temperature
    # end
    # # NOTE: could average all current temperatures (if more then one)
    # def wind
    #   self.current.wind
    # end
    # # NOTE: could average all current temperatures (if more then one)
    # def pressure
    #   self.current.pressure
    # end
    # # NOTE: could average all current dew_point (if more then one)
    # def dew_point
    #   self.current.dew_point
    # end
    # # NOTE: could average all current heat_index (if more then one)
    # def heat_index
    #   self.current.heat_index
    # end
    # # NOTE: could average all current wind_chill (if more then one)
    # def wind_chill
    #   self.current.wind_chill
    # end
    # def visibility
    #   self.current.visibility
    # end
    
  end
  
end