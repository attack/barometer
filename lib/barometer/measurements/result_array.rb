require 'date'
module Barometer
  #
  # Result Array
  #
  # an array that holds multiple results,
  # with methods for insertion and searching
  #
  class Measurement::ResultArray < Array
    
    def <<(forecast)
      raise ArgumentError unless forecast.is_a?(Measurement::Result)
      super(forecast)
    end
    
    def [](index)
      index.is_a?(Fixnum) ? super(index) : self.for(index)
    end
    
    #
    # Returns a forecast for a day given by a Date, DateTime,
    # Time, or a string that can be parsed to a Data::LocalDateTime
    #
    # credit: http://github.com/jdpace/weatherman/
    #
    def for(datetime)
    
      return nil unless self.size > 0
      
      # Format date into a Date class
      datetime = case datetime.class.name
      when 'Date'
        # if just given a date, assume a time that will be mid-day
        Data::LocalDateTime.new(datetime.year,datetime.month,datetime.day,12,0,0)
      when 'Data::LocalDateTime'
        datetime
      when 'String'
        Data::LocalDateTime.parse(datetime)
      when 'Time'
        Data::LocalDateTime.parse(datetime)
      when 'DateTime'
        Data::LocalDateTime.parse(datetime)
      end
      
      day = nil
      self.each do |f|
        day = f if f.for_datetime?(datetime)
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
