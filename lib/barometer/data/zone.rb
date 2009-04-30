require 'rubygems'
require 'tzinfo'

module Barometer
  #
  # A simple Zone class
  # 
  # Used for building and converting timezone aware date and times
  # Really, these are just wrappers for TZInfo conversions.
  #
  class Zone
    
    attr_accessor :timezone, :tz
    
    def initialize(timezone)
      @timezone = timezone
      @tz = TZInfo::Timezone.get(timezone)
    end
    
    # what is the Timezone Short Code for the current timezone
    def code
      return "" unless @tz
      @tz.period_for_utc(Time.now.utc).zone_identifier.to_s
    end
    
    # is the current timezone in daylights savings mode?
    def dst?
      return nil unless @tz
      @tz.period_for_utc(Time.now.utc).dst?
    end
    
    # return Time.now.utc for the set timezone
    def now
      Barometer::Zone.now(@timezone)
    end
    
    # return Date.today for the set timezone
    def today
      Barometer::Zone.today(@timezone)
    end
    
    def local_to_utc(local_time)
      @tz.local_to_utc(local_time)
    end
    
    def utc_to_local(utc_time)
      @tz.utc_to_local(utc_time)
    end
    
    #
    # Class Methods
    #
    
    # return the local current time, providing a timezone
    # (ie 'Europe/Paris') will give the local time for the
    # timezone, otherwise it will be Time.now
    def self.now(timezone=nil)
      if timezone
        utc = Time.now.utc
        tz = TZInfo::Timezone.get(timezone)
        tz.utc_to_local(utc)
      else
        Time.now
      end
    end
    
    # return the local current date, providing a timezone
    # (ie 'Europe/Paris') will give the local date for the
    # timezone, otherwise it will be Date.today
    def self.today(timezone=nil)
      if timezone
        utc = Time.now.utc
        tz = TZInfo::Timezone.get(timezone)
        now = tz.utc_to_local(utc)
        Date.new(now.year, now.month, now.day)
      else
        Date.today
      end
    end
    
    # takes a time (any timezone), and a TimeZone Short Code (ie PST) and
    # converts the time to UTC accorsing to that time_zone
    # NOTE: No Tests
    def self.code_to_utc(time, timezone_code)
      raise ArgumentError unless time.is_a?(Time)
      offset = Time.zone_offset(timezone_code) || 0
      
      Time.utc(
        time.year, time.month, time.day,
        time.hour, time.min, time.sec, time.usec
      ) - offset
    end
    
    # takes a string with TIME only information and merges it with a string that
    # has DATE only information and creates a UTC TIME object with time and date
    # info.  if you supply the timezone code (ie PST), it will apply the timezone
    # offset to the final time
    def self.merge(time, date, timezone_code=nil)
      raise ArgumentError unless (time.is_a?(Time) || time.is_a?(String))
      raise ArgumentError unless (date.is_a?(Time) || date.is_a?(Date) || date.is_a?(String))
      
      if time.is_a?(String)
        reference_time = Time.parse(time)
      elsif time.is_a?(Time)
        reference_time = time
      end
      
      if date.is_a?(String)
        reference_date = Date.parse(date)
      elsif date.is_a?(Time)
        reference_date = Date.new(date.year, date.month, date.day)
      elsif date.is_a?(Date)
        reference_date = date
      end
      
      new_time = Time.utc(
        reference_date.year, reference_date.month, reference_date.day,
        reference_time.hour, reference_time.min, reference_time.sec
      )
      timezone_code ? Barometer::Zone.code_to_utc(new_time,timezone_code) : new_time
    end
    
  end
end