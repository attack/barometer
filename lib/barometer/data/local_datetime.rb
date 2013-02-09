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

    def initialize(y,mon,d,h=0,m=0,s=0)
      raise(ArgumentError, "invalid date") unless y && mon && d && Date.civil(y,mon,d)
      @year = y
      @month = mon
      @day = d
      super(h,m,s)
      self
    end

    def year=(y)
      unless y && y.is_a?(Fixnum) && Date.civil(y,@month,@day)
        raise(ArgumentError, "invalid year")
      end
      @year = y
    end

    def month=(m)
      unless m && m.is_a?(Fixnum) && Date.civil(@year,m,@day)
        raise(ArgumentError, "invalid month")
      end
      @month = m
    end

    def day=(d)
      unless d && d.is_a?(Fixnum) && Date.civil(@year,@month,d)
        raise(ArgumentError, "invalid day")
      end
      @day = d
    end

    def parse(string, format=nil)
      return unless string
      new_date = Data::LocalDateTime.parse(string, format)
      @year = new_date.year
      @month = new_date.month
      @day = new_date.day
      @hour = new_date.hour
      @min = new_date.min
      @sec = new_date.sec
      self
    end

    def self.parse(string, format=nil)
      return nil unless string
      return string if string.is_a?(Data::LocalDateTime)

      year = nil; month = nil; day = nil;
      hour = nil; min = nil; sec = nil;
      if string.is_a?(Time) || string.is_a?(DateTime)
        year = string.year
        month = string.mon
        day = string.day
        hour = string.hour
        min = string.min
        sec = string.sec
      elsif string.is_a?(Date)
        year = string.year
        month = string.mon
        day = string.day
      elsif string.is_a?(String)
        begin
          datetime = if format
            Time.strptime(string, format)
          else
            DateTime.parse(string)
          end
          year = datetime.year
          month = datetime.mon
          day = datetime.day
          hour = datetime.hour
          min = datetime.min
          sec = datetime.sec
        rescue ArgumentError
          return nil
        end
      end
      Data::LocalDateTime.new(year, month, day, hour, min, sec)
    end

    # convert to a Date class
    #
    def to_d
      Date.civil(@year, @month, @day)
    end

    # convert to a DateTime class
    #
    def to_dt
      DateTime.new(@year, @month, @day, @hour, @min, @sec)
    end

    def <=>(other)
      if other.is_a?(String) || other.is_a?(Time) || other.is_a?(DateTime) || other.is_a?(Date)
        the_other = Data::LocalDateTime.parse(other)
      else
        the_other = other
      end
      raise ArgumentError unless the_other.is_a?(Data::LocalDateTime) || the_other.is_a?(Data::LocalTime)

      if ((other.is_a?(String) || other.is_a?(Time) || other.is_a?(DateTime)) &&
        the_other.is_a?(Data::LocalDateTime)) || other.is_a?(Data::LocalDateTime)
        # we are counting days + seconds
        if (_total_days <=> the_other._total_days) == 0
          return total_seconds <=> the_other.total_seconds
        else
          return _total_days <=> the_other._total_days
        end
      elsif other.is_a?(Date) && the_other.is_a?(Data::LocalDateTime)
        # we are counting days
        return _total_days <=> the_other._total_days
      elsif the_other.is_a?(Data::LocalTime)
        # we are counting seconds
        return total_seconds <=> the_other.total_seconds
      end
    end

    def to_s(time=false)
      datetime = self.to_dt
      format = (time ? "%Y-%m-%d %I:%M:%S %p" : "%Y-%m-%d")
      datetime.strftime(format).downcase
    end

    def nil?; @year == 0 && @month == 0 && @day == 0 && super; end

    # this assumes all years have 366 days (which only is true for leap years)
    # but since this is just for comparisons, this will be accurate
    #
    def _total_days
      self.to_d.yday + (@year * 366)
    end

  end
end
