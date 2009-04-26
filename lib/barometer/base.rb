module Barometer

  class Base
    
    # allow the configuration of specific weather APIs to be used,
    # and the order in which they would be used
    @@selection = { 1 => [:wunderground] }
    def self.selection; @@selection; end;
    def self.selection=(hash); @@selection = hash; end;
    
    attr_reader   :query
    attr_accessor :weather, :success
    
    def initialize(query=nil)
      @query = Barometer::Query.new(query)
      @weather = Barometer::Weather.new
      @success = false
    end
    
    def measure(metric=nil)
      return nil unless @query

      level = 1
      until self.success?
        if sources = @@selection[level]
          if sources.is_a?(Array)
            sources.each do |source|
              measurement = Barometer.source(source.to_sym).measure(@query, metric)
              @success = true if measurement.success?
              @weather.measurements << measurement
            end
          else  
            measurement = Barometer.source(sources.to_sym).measure(@query, metric)
            @success = true if measurement.success?
            @weather.measurements << measurement
          end
        else
          raise OutOfSources
        end
        level += 1
      end
      
      @weather
    end
    
    def success?
      @success
    end

  end

end