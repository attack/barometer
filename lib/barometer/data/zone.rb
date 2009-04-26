module Barometer
  #
  # A simple Zone class
  # 
  # Used for building and converting timezone aware date and times
  #
  class Zone
    
    @@use_tzinfo = false
    
    attr_accessor :time_as_utc, :timezone, :tz
    
    def initialize(time=nil, timezone=nil)
      @time_as_utc = time
      @timezone = timezone
      if timezone && Barometer::Zone.tzinfo?
        @tz = TZInfo::Timezone.get(timezone)
      end
    end
    
    def code
      return "" unless @tz
      @tz.period_for_utc(Time.now.utc).zone_identifier.to_s
    end
    
    def dst?
      return nil unless @tz
      @tz.period_for_utc(Time.now.utc).dst?
    end
    
    def utc
      @time_as_utc
    end
    
    def local
      return @time_as_utc unless @tz
      @tz.utc_to_local(@time_as_utc)
    end
    
    def now
      Barometer::Zone.now(@timezone)
    end
    
    def today
      Barometer::Zone.today(@timezone)
    end
    
    def self.now(timezone=nil)
      if timezone && self.tzinfo?
        utc = Time.now.utc
        tz = TZInfo::Timezone.get(timezone)
        tz.utc_to_local(utc)
      else
        Time.now
      end
    end
    
    def self.today(timezone=nil)
      if timezone && self.tzinfo?
        utc = Time.now.utc
        tz = TZInfo::Timezone.get(timezone)
        now = tz.utc_to_local(utc)
        Date.new(now.year, now.month, now.day)
      else
        Date.today
      end
    end
    
    def self.tzinfo?
      @@use_tzinfo || Barometer::Zone.load_tzinfo
    end
    
    def self.load_tzinfo
      return true if @@use_tzinfo
      begin
        require 'rubygems'
        require 'tzinfo'
        $:.unshift(File.dirname(__FILE__))
        @@use_tzinfo = true
      rescue LoadError
        # do nothing
      end
      @@use_tzinfo
    end
    
  end
end