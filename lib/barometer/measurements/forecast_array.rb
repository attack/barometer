require 'date'
module Barometer
  #
  # Forecast Array
  # an array that holds multiple forecasts
  #
  class Measurement::ForecastArray < Array
    
    def <<(forecast)
      raise ArgumentError unless forecast.is_a?(Measurement::Forecast)
      super(forecast)
    end
    
    def [](index)
      index.is_a?(Fixnum) ? super(index) : self.for(index)
    end
    
    #
    # Returns a forecast for a day given by a Date, DateTime,
    # Time, or a string that can be parsed to a date
    #
    # credit: http://github.com/jdpace/weatherman/
    #
    def for(date)
    
      return nil unless self.size > 0
      
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
      self.each do |f|
        day = f if date == f.date
      end
      return day
    end
    
    #
    # answer simple questions
    #
    
    def windy?(datetime, threshold=10)
      (forecast = self[datetime]) ? forecast.windy?(threshold) : nil
    end
    
    def day?(datetime)
      local_time = Data::LocalTime.parse(datetime)
      (forecast = self[datetime]) ? forecast.day?(local_time) : nil
    end
    
    def sunny?(datetime, sunny_icons=nil)
      local_time = Data::LocalTime.parse(datetime)
      (forecast = self[datetime]) ? forecast.sunny?(local_time, sunny_icons) : nil
    end
    
    def wet?(datetime, wet_icons=nil, pop_threshold=50, humidity_threshold=99)
      (forecast = self[datetime]) ? forecast.wet?(wet_icons,pop_threshold,humidity_threshold) : nil
    end
    
  end
end
