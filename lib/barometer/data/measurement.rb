module Barometer
  #
  # Measurement
  # a class that holds the response from a weather service
  #
  # its main purpose is to hold all the data collected from a weather service
  # as it is passed to the weather object
  #
  # this response includes
  # - current weather data (using the CurrentMeasurement class)
  # - forecasted weather data (an Array of instances of the ForecastMeasurement class)
  # - time_zone information (for the location in question)
  # - weather station information (for the station that gave collected the data)
  #
  class Measurement
    
    # the weather service source
    attr_reader :source
    # current and forecasted data
    attr_reader :current, :forecast
    attr_reader :timezone, :station, :location, :sun
    attr_reader :success, :time
    attr_accessor :metric
    
    def initialize(source=nil, metric=true)
      @source = source
      @metric = metric
      @success = false
    end
    
    def success!
      if current && current.temperature && !current.temperature.c.nil?
        @success = true
      end
    end
    
    def stamp!; @time = Time.now.utc; end
    def success?; @success; end
    def metric?; @metric; end
    def metric!; @metric=true; end
    def imperial!; @metric=false; end
    
    # this will tell us if the measurement is still current ... if it is still
    # current this means that the CurrentMeasurement can still used as now
    #
    # what it also means is that if you took a measurement right now (time = now)
    # and then asked if current?(time_in_future) that current? would be true for
    # any time_in_future within 4 hours of now
    #
    # where is this useful?  lets say you take the measurement now (time = now),
    # and then you want to know if self.windy?(5_hours_in_future) ... we could
    # not use the current data for this answser as the time 5_hours_in_future
    # is not current
    def current?(utc_time=Time.now.utc)
      return false unless @time
      raise ArgumentError unless utc_time.is_a?(Time)
      hours_still_current = 4
      difference = (@time - utc_time).to_i
      difference = (difference*(-1)).to_i if difference < 0
      difference <= (60*60*hours_still_current).to_i
    end
    
    #
    # Returns a forecast for a day given by a Date, DateTime,
    # Time, or a string that can be parsed to a date
    #
    # credit: http://github.com/jdpace/weatherman/
    #
    def for(date=nil)
      date = @timezone.today unless date || !@timezone
      date ||= Date.today
      return nil unless (@forecast && @forecast.size > 0)
      
      # Format date into a Date class
      date = case date.class.name
      when 'String'
        Date.parse(date)
      when 'Date'
        date
      when 'DateTime'
        Date.new(date.year, date.month, date.day)
      when 'Time'
        Date.new(date.year, date.month, date.day)
      end

      day = nil
      @forecast.each do |f|
        day = f if date == f.date
      end
      return day
    end
    
    def source=(source)
      raise ArgumentError unless source.is_a?(Symbol)
      @source = source
    end
    
    def time=(time=Time.now.utc)
      raise ArgumentError unless time.is_a?(Time)
      @time = time
    end
    
    def current=(current)
      raise ArgumentError unless current.is_a?(Barometer::CurrentMeasurement)
      @current = current
      self.stamp!
      # self-determine success
      self.success!
    end
    
    def forecast=(forecast)
      raise ArgumentError unless forecast.is_a?(Array)
      @forecast = forecast
    end
    
    def timezone=(timezone)
      #raise ArgumentError unless timezone.is_a?(String)
      raise ArgumentError unless timezone.is_a?(Barometer::Zone)
      @timezone = timezone
    end
    
    def station=(station)
      raise ArgumentError unless station.is_a?(Barometer::Location)
      @station = station
    end
    
    def location=(location)
      raise ArgumentError unless location.is_a?(Barometer::Location)
      @location = location
    end
    
    def sun=(sun)
      raise ArgumentError unless sun.is_a?(Barometer::Sun)
      @sun = sun
    end
    
    #
    # simple questions
    # pass questions to the source
    #
    
    def windy?(threshold=10, utc_time=Time.now.utc)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless utc_time.is_a?(Time)
      Barometer::Service.source(@source).windy?(self, threshold, utc_time)
    end
    
    def wet?(threshold=50, utc_time=Time.now.utc)
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless utc_time.is_a?(Time)
      Barometer::Service.source(@source).wet?(self, threshold, utc_time)
    end
    
  end
end