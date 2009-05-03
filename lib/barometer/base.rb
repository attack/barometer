module Barometer

  class Base
    
    # { 1 => { :wunderground => { :key => "", :weight => 2 },
    #          :yahoo        => { :key => "", :weight => 1 } }
    
    # allow the configuration of specific weather APIs to be used,
    # and the order in which they would be used
    @@config = { 1 => [:wunderground] }
    def self.config; @@config; end;
    def self.config=(hash); @@config = hash; end;
    
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
        if sources = @@config[level]
          _dig(sources, metric)
        else
          raise OutOfSources
        end
        level += 1
      end
      @weather
    end
    
    def success?; @success; end
    
    private
    
    # iterate through the setup until we have a source name (and possibly
    # a config for that source), then measure with that source
    #
    # this allows for many different config formats, like
    # { 1 => :wunderground }
    # { 1 => [:wunderground]}
    # { 1 => [:wunderground, :yahoo]}
    # { 1 => [:wunderground, {:yahoo => {:weight => 2}}]}
    # { 1 => {:wunderground => {:weight => 2}}}
    # { 1 => [{:wunderground => {:weight => 2}}]}
    def _dig(data, config=nil, metric=nil)
      if data.is_a?(String) || data.is_a?(Symbol)
        _measure(data, config, metric)
      elsif data.is_a?(Array)
        data.each do |datum|
          _dig(datum, config, metric)
        end
      elsif data.is_a?(Hash)
        data.each do |datum, config|
          _dig(datum, config, metric)
        end
      end
    end
    
    # do that actual source measurement
    def _measure(datum, config=nil, metric=nil)
      measurement = Barometer.source(datum.to_sym).measure(@query, metric)
      if config && config[:weight]
        measurement.weight = config[:weight]
      end
      @success = true if measurement.success?
      @weather.measurements << measurement
      # do something with the config
    end

  end

end