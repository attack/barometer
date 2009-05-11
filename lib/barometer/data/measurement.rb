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
  class Data::Measurement
    
    attr_reader :source, :weight
    attr_reader :measured_at, :utc_time_stamp
    attr_reader :current, :forecast
    attr_reader :timezone, :station, :location, :links
    attr_reader :success
    attr_accessor :metric, :query, :format
    
    def initialize(source=nil, metric=true)
      @source = source
      @metric = metric
      @success = false
      @weight = 1
      @links = {}
    end
    
    def success!
       current && current.temperature &&
         !current.temperature.c.nil? && @success = true
    end
    
    def stamp!; @utc_time_stamp = Time.now.utc; end
    def success?; @success; end
    def metric?; @metric; end
    def metric!; @metric=true; end
    def imperial!; @metric=false; end
    
    #
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
    #
    def current?(local_time=nil)
      current_at = ((self.current && self.current.current_at) ?
        self.current.current_at : self.measured_at)
      
      local_time = (local_time.nil? ? current_at : Data::LocalTime.parse(local_time))
      return false unless local_time
      raise ArgumentError unless local_time.is_a?(Data::LocalTime)
      
      hours_still_current = 4
      difference = (local_time.diff(current_at)).to_i.abs
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
      when 'Date'
        date
      when 'Data::LocalDateTime'
        date.to_d
      when 'String'
        Date.parse(date)
      when 'Time'
        Date.new(date.year, date.month, date.day)
      when 'DateTime'
        Date.new(date.year, date.month, date.day)
      end
      
      day = nil
      @forecast.each do |f|
        day = f if date == f.date
      end
      return day
    end
    
    #
    # accesors (with input checking)
    #
    
    def source=(source)
      raise ArgumentError unless source.is_a?(Symbol)
      @source = source
    end
    
    def utc_time_stamp=(time=Time.now.utc)
      raise ArgumentError unless time.is_a?(Time)
      @utc_time_stamp = time
    end
    
    def current=(current)
      raise ArgumentError unless current.is_a?(Data::CurrentMeasurement)
      @current = current
      self.stamp!
      self.success!
    end
    
    def forecast=(forecast)
      raise ArgumentError unless forecast.is_a?(Array)
      @forecast = forecast
    end
    
    def timezone=(timezone)
      return unless timezone
      raise ArgumentError unless timezone.is_a?(Data::Zone)
      @timezone = timezone
    end
    
    def station=(station)
      raise ArgumentError unless station.is_a?(Data::Location)
      @station = station
    end
    
    def location=(location)
      raise ArgumentError unless location.is_a?(Data::Location)
      @location = location
    end
    
    def weight=(weight)
      raise ArgumentError unless weight.is_a?(Fixnum)
      @weight = weight
    end
    
    def links=(links)
      raise ArgumentError unless links.is_a?(Hash)
      @links = links
    end
    
    def measured_at=(measured_at)
      raise ArgumentError unless measured_at.is_a?(Data::LocalTime)
      @measured_at = measured_at
    end
    
    #
    # simple questions
    # pass questions to the source
    #
    
    def windy?(threshold=10, time_string=nil)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)
      Barometer::WeatherService.source(@source).windy?(self, threshold, local_datetime)
    end
    
    def wet?(threshold=50, time_string=nil)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless (threshold.is_a?(Fixnum) || threshold.is_a?(Float))
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)
      Barometer::WeatherService.source(@source).wet?(self, threshold, local_datetime)
    end
    
    def day?(time_string=nil)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)
      Barometer::WeatherService.source(@source).day?(self, local_datetime)
    end
    
    def sunny?(time_string=nil)
      local_datetime = Data::LocalDateTime.parse(time_string) if time_string
      raise ArgumentError unless (local_datetime.is_a?(Data::LocalDateTime) || local_datetime.nil?)
      return false if self.day?(local_datetime) == false
      Barometer::WeatherService.source(@source).sunny?(self, local_datetime)
    end
    
  end
end