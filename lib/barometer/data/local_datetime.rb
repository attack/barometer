require 'date'
module Barometer
  #
  # A simple DateTime class
  # 
  # A time class that represents the local date_time ...
  # it has no concept of time zone
  #
  class Data::LocalDateTime < Data::LocalTime
    
    attr_reader :year, :month, :day

    def initialize(y=0,mon=0,d=0,h=0,m=0,s=0)
      self.year = y
      self.month = mon
      @day = d
#      self.day = day
      super(h,m,s)
      self
    end
    
    def year=(y)
      raise ArgumentError unless (y.is_a?(Fixnum) || y.nil?)
      @year = y
    end
    
    def month=(m)
      raise ArgumentError unless (m.is_a?(Fixnum) || m.nil?)
      month_cap = 12
      if m.to_i >= month_cap.to_i
        result = m.divmod(month_cap)
        @month = result[1]
        self.year = @year + result[0]
      else
        @month = m
      end
    end
    
def day=(d)
  @day = d
end
    
    # def day=(s)
    #   raise ArgumentError unless (s.is_a?(Fixnum) || s.nil?)
    #   second_cap = 60
    #   if s.to_i >= second_cap.to_i
    #     result = s.divmod(second_cap)
    #     @sec = result[1]
    #     self.min = @min + result[0]
    #   else
    #     @sec = s
    #   end
    # end
  
    def parse(string)
      if string.is_a?(Time) || string.is_a?(DateTime)
        @year = string.year
        @month = string.mon
        @day = string.day
        @hour = string.hour
        @min = string.min
        @sec = string.sec
      elsif string.is_a?(Date)
        @year = string.year
        @month = string.mon
        @day = string.day
      elsif string.is_a?(String)
        datetime = Time.parse(string)
        @year = datetime.year
        @month = datetime.mon
        @day = datetime.day
        @hour = datetime.hour
        @min = datetime.min
        @sec = datetime.sec
      end
      self
    end
    
    def self.parse(string)
      return string if string.is_a?(Data::LocalDateTime)
      local = Data::LocalDateTime.new
      local.parse(string)
      local
    end
    
    # convert to a Date class
    def to_d
      return nil if self.nil? 
      Date.civil(@year, @month, @day)
    end
    
    # convert to a DateTime class
    def to_dt
      DateTime.new(@year, @month, @day, @hour, @min, @sec)
    end
    
    # improve this
    def total_days
      (@year * 365) + (@month * 31) + @day
    end

    def <=>(other)
      if other.is_a?(String) || other.is_a?(Time) || other.is_a?(DateTime) || other.is_a?(Date)
        the_other = Data::LocalDateTime.parse(other)
      else
        the_other = other
      end
      raise ArgumentError unless the_other.is_a?(Data::LocalDateTime) || the_other.is_a?(Data::LocalTime)
      
      if (other.is_a?(String) || other.is_a?(Time) || other.is_a?(DateTime)) &&
        the_other.is_a?(Data::LocalDateTime)
        # we are counting days + seconds
        if (total_days <=> the_other.total_days) == 0
          return total_seconds <=> the_other.total_seconds
        else
          return total_days <=> the_other.total_days
        end
      elsif other.is_a?(Date) && the_other.is_a?(Data::LocalDateTime)
        # we are counting days
        return total_days <=> the_other.total_days
      elsif the_other.is_a?(Data::LocalTime)
        # we are counting seconds
        return total_seconds <=> the_other.total_seconds
      end
    end
    
    # def +(seconds)
    #   local_time = Data::LocalTime.new
    #   if seconds.is_a?(Fixnum) || seconds.is_a?(Float)
    #     local_time.sec = self.total_seconds + seconds.to_i
    #   elsif seconds.is_a?(Data::LocalTime)
    #     this_total = self.total_seconds + seconds.total_seconds
    #     local_time.sec = this_total
    #   end
    #   local_time
    # end

    # def -(seconds)
    #   local_time = Data::LocalTime.new
    #   if seconds.is_a?(Fixnum) || seconds.is_a?(Float)
    #     local_time.sec = self.total_seconds - seconds.to_i
    #   elsif seconds.is_a?(Data::LocalTime)
    #     #self.sec += seconds.total_seconds
    #     this_total = self.total_seconds - seconds.total_seconds
    #     local_time.sec = this_total
    #   end
    #   local_time
    # end

    # def diff(other)
    #   the_other = Data::LocalTime.parse(other)
    #   raise ArgumentError unless the_other.is_a?(Data::LocalTime)
    #   (self.total_seconds - the_other.total_seconds).to_i.abs
    # end
  
    # def to_s(seconds=false)
    #   time = self.to_t
    #   format = (seconds ? "%I:%M:%S %p" : "%I:%M %p")
    #   time.strftime(format).downcase
    # end
    
    def nil?
      @year == 0 && @month == 0 && @day == 0 && super
    end
    
  end
end
