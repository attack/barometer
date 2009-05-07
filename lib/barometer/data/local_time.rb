module Barometer
  #
  # A simple Time class
  # 
  # A time class that represents the local time ...
  # it has no concept of time zone or date
  #
  class Data::LocalTime
    include Comparable
    
    attr_reader :hour, :min, :sec

    def initialize(h=0,m=0,s=0)
      self.hour = h
      self.min = m
      self.sec = s
      self
    end
    
    def hour=(h)
      raise ArgumentError unless (h.is_a?(Fixnum) || h.nil?)
      hour_cap = 24
      if h.to_i >= hour_cap.to_i
        @hour = h.divmod(hour_cap)[1]
      else
        @hour = h
      end
    end
    
    def min=(m)
      raise ArgumentError unless (m.is_a?(Fixnum) || m.nil?)
      minute_cap = 60
      if m.to_i >= minute_cap.to_i
        result = m.divmod(minute_cap)
        @min = result[1]
        self.hour = @hour + result[0]
      else
        @min = m
      end
    end
    
    def sec=(s)
      raise ArgumentError unless (s.is_a?(Fixnum) || s.nil?)
      second_cap = 60
      if s.to_i >= second_cap.to_i
        result = s.divmod(second_cap)
        @sec = result[1]
        self.min = @min + result[0]
      else
        @sec = s
      end
    end
    
    def parse(string)
      if string.is_a?(Time) || string.is_a?(DateTime)
        @hour = string.hour
        @min = string.min
        @sec = string.sec
      elsif string.is_a?(String)
        time = Time.parse(string)
        @hour = time.hour
        @min = time.min
        @sec = time.sec
      end
      self
    end
    
    def self.parse(string)
      return string if string.is_a?(Data::LocalTime)
      local = Data::LocalTime.new
      local.parse(string)
      local
    end
    
    # convert to a Time class
    #
    def to_t
      date = Date.today
      Time.local(date.year,date.month,date.day,@hour,@min,@sec)
    end
    
    def total_seconds
      (@hour * 60 * 60) + (@min * 60) + @sec
    end

    def <=>(other)
      if other.is_a?(String) || other.is_a?(Time) || other.is_a?(DateTime)
        the_other = Data::LocalTime.parse(other)
      else
        the_other = other
      end
      raise ArgumentError unless the_other.is_a?(Data::LocalTime)
      total_seconds <=> the_other.total_seconds
    end
    
    def +(seconds)
      local_time = Data::LocalTime.new
      if seconds.is_a?(Fixnum) || seconds.is_a?(Float)
        local_time.sec = self.total_seconds + seconds.to_i
      elsif seconds.is_a?(Data::LocalTime)
        this_total = self.total_seconds + seconds.total_seconds
        local_time.sec = this_total
      end
      local_time
    end

    def -(seconds)
      local_time = Data::LocalTime.new
      if seconds.is_a?(Fixnum) || seconds.is_a?(Float)
        local_time.sec = self.total_seconds - seconds.to_i
      elsif seconds.is_a?(Data::LocalTime)
        #self.sec += seconds.total_seconds
        this_total = self.total_seconds - seconds.total_seconds
        local_time.sec = this_total
      end
      local_time
    end

    def diff(other)
      the_other = Data::LocalTime.parse(other)
      raise ArgumentError unless the_other.is_a?(Data::LocalTime)
      (self.total_seconds - the_other.total_seconds).to_i.abs
    end
  
    def to_s(seconds=false)
      time = self.to_t
      format = (seconds ? "%I:%M:%S %p" : "%I:%M %p")
      time.strftime(format).downcase
    end
    
    def nil?; @hour == 0 && @min == 0 && @sec == 0; end
    
  end
end
