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
    attr_reader :timezone, :station
    attr_reader :success
    
    def initialize(source=nil)
      @source = source
      @success = false
    end
    
    def success!
      @success = true
    end
    
    def success?
      @success
    end
    
    #
    # Returns a forecast for a day given by a Date, DateTime,
    # Time, or a string that can be parsed to a date
    #
    # credit: http://github.com/jdpace/weatherman/
    #
    def for(date = Date.today)
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
    
    def current=(current)
      raise ArgumentError unless current.is_a?(Barometer::CurrentMeasurement)
      @current = current
    end
    
    def forecast=(forecast)
      raise ArgumentError unless forecast.is_a?(Array)
      @forecast = forecast
    end
    
    def timezone=(timezone)
      raise ArgumentError unless timezone.is_a?(String)
      @timezone = timezone
    end
    
    def station=(station)
      raise ArgumentError unless station.is_a?(Hash)
      @station = station
    end
    
  end
end