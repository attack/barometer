module Barometer
  class Weather
    attr_accessor :measurements
    attr_accessor :start_at, :end_at

    def initialize
      @measurements = []
    end

    # the default measurement is the first successful measurement
    #
    def default
      return nil unless self.sources
      self.source(self.sources.first)
    end

    def source(source)
      raise ArgumentError unless (source.is_a?(String) || source.is_a?(Symbol))
      @measurements.each do |measurement|
        return measurement if measurement.source == source.to_sym
      end
      nil
    end

    def sources
      @measurements.collect {|m| m.source.to_sym if m.success?}.compact
    end

    def success?
      @measurements.any?{ |m| m.success? }
    end

    def metric?; self.default ? self.default.metric? : true; end
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

    # measurement search
    # this will search the default measurements forecasts looking for
    # the matching date
    #
    def for(query)
      default = self.default
      default && default.forecast ? default.for(query) : nil
    end

    #
    # averages
    #

    # this assumes calculating for current, and that "to_f" for a value
    # will return the value needed
    # value_name = the name of the value we are averaging
    # if a measurement has weighting, it will respect that
    #
    def current_average(value_name)
      values = []
      @measurements.each do |measurement|
        if measurement.weight && measurement.weight > 1
          measurement.weight.times do
            values << measurement.current.send(value_name).to_f if measurement.success? &&
              !measurement.current.send(value_name).nil?
          end
        else
          values << measurement.current.send(value_name).to_f if measurement.success? &&
            !measurement.current.send(value_name).nil?
        end
      end
      values.compact!
      return nil unless values && values.size > 0
      values.inject(0.0) { |sum,v| sum += v if v } / values.size
    end

    def average(value_name, do_average=true, class_name=nil)
      if class_name
        if do_average
          if %w(Vector Distance Pressure Temperature).include?(class_name)
            if metric?
              avg = Barometer::Data.const_get(class_name).new(self.metric?, self.current_average(value_name), nil, nil)
            else
              avg = Barometer::Data.const_get(class_name).new(self.metric?, nil, self.current_average(value_name), nil)
            end
          else
            avg = Barometer::Data.const_get(class_name).new(self.metric?)
            avg << self.current_average(value_name)
          end
        else
          avg = self.now.send(value_name)
        end
      else
        avg = (do_average ? self.current_average(value_name) : self.now.send(value_name))
      end
      avg
    end

    def humidity(do_average=true); average("humidity",do_average); end
    def temperature(do_average=true); average("temperature",do_average,"Temperature"); end
    def wind(do_average=true); average("wind",do_average,"Vector"); end
    def pressure(do_average=true); average("pressure",do_average,"Pressure"); end
    def dew_point(do_average=true); average("dew_point",do_average,"Temperature"); end
    def heat_index(do_average=true); average("heat_index",do_average,"Temperature"); end
    def wind_chill(do_average=true); average("wind_chill",do_average,"Temperature"); end
    def visibility(do_average=true); average("visibility",do_average,"Distance"); end
  end
end
