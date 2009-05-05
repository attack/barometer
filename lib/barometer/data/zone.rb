require 'rubygems'
require 'tzinfo'

module Barometer
  #
  # A simple Zone class
  # 
  # Used for building and converting timezone aware date and times
  # Really, these are just wrappers for TZInfo conversions.
  #
  class Data::Zone
    
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
      Data::Zone.now(@timezone)
    end
    
    # return Date.today for the set timezone
    def today
      Data::Zone.today(@timezone)
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
    
    # takes a time (any timezone), and a TimeZone Short Code (ie PST) or
    # the number of hours offset from UTC time and
    # converts the time to UTC according to that time_zone
    # NOTE: No Tests
    def self.code_to_utc(time, timezone)
      raise ArgumentError unless time.is_a?(Time)
      
      offset = self.zone_to_offset(timezone)
      
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
      timezone_code ? Data::Zone.code_to_utc(new_time,timezone_code) : new_time
    end
    
    #
    # Known conflicts
    # IRT (ireland and india)
    # CST (central standard time, china standard time)
    #
    def self.zone_to_offset(timezone)
      offset = 0
      seconds_in_hour = 60*60
      # do we have a short_timezone code, or an offset?
      if timezone.is_a?(Fixnum) || 
         (timezone.is_a?(String) && timezone.to_i.to_s == timezone)
        # we have an offset, convert to second
        offset = timezone.to_i * seconds_in_hour
      else
        # try to use Time
        unless offset = Time.zone_offset(timezone)
          # that would have been too easy, do it manually
          # http://www.timeanddate.com/library/abbreviations/timezones/
          # http://www.worldtimezone.com/wtz-names/timezonenames.html
          zone_offsets = {
            :A => 1, :ACDT => 10.5, :ACST => 9.5, :ADT => -3, :AEDT => 11,
            :AEST => 10, :AFT => 4.5, :AHDT => -9, :AHST => -10, :AKDT => -8,
            :AKST => -9, :AMST => 5, :AMT => 4, :ANAST => 13, :ANAT => 12,
            :ART => -3, :AST => -4, :AT => -1, :AWDT => 9, :AWST => 8,
            :AZOST => 0, :AZOT => -1, :AZST => 5, :AZT => 4,
            
            :B => 2, :BADT => 4, :BAT => 6, :BDST => 2, :BDT => 6, :BET => -11,
            :BNT => 8, :BORT => 8, :BOT => -4, :BRA => -3, :BST => 1, :BT => 6,
            :BTT => 6,
            
            :C => 3, :CAT => 2, :CCT => 8, :CEST => 2, :CET => 1, :CHADT => 13.75,
            :CHAST => 12.75, :CHST => 10, :CKT => -10, :CLST => -3, :CLT => -4,
            :COT => -5, :CUT => 0, :CVT => -1, :CWT => 8.75, :CXT => 7, :CEDT => 2,
            
            :D => 4, :DAVT => 7, :DDUT => 10, :DNT => 1, :DST => 2,
            
            :E => 5, :EASST => -5, :EAST => -6, :EAT => 3, :ECT => -5, :EEST => 3,
            :EET => 2, :EGST => 0, :EGT => -1, :EMT => 1, :EEDT => 3,
            
            :F => 6, :FDT => -1, :FJST => 13, :FJT => 12, :FKST => -3, :FKT => -4,
            :FST => 2, :FWT => 1,
            
            :G => 7, :GALT => -6, :GAMT => -9, :GEST => 5, :GET => 4, :GFT => -3,
            :GILT => 12, :GST => 4, :GT => 0, :GYT => -4, :GZ => 0,
            
            :H => 8, :HAA => -3, :HAC => -5, :HADT => -9, :HAE => -4, :HAP => -7,
            :HAR => -6, :HAST => -10, :HAT => -2.5, :HAY => -8, :HDT => -9.5,
            :HFE => 2, :HFH => 1, :HG => 0, :HKT => 8, :HNA => -4, :HNC => -6,
            :HNE => -5, :HNP => -8, :HNR => -7, :HNT => -3.5, :HNY => -9,
            :HOE => 1, :HST => -10,
            
            :I => 9, :ICT => 4, :IDLE => 12, :IDLW => -12, :IDT => 1, :IOT => 5,
            :IRDT => 4.5, :IRKST => 9, :IRKT => 8, :IRST => 3.5, :IRT => 3.5,
            :IST => 1, :IT => 3.5, :ITA => 1,
            
            :JAVT => 7, :JAYT => 9, :JFDT => -3, :JFST => -4, :JST => 9, :JT => 7,
            
            :K => 10, :KDT => 10, :KGST => 6, :KGT => 5, :KOST => 12, :KOVT => 7,
            :KOVST => 8, :KRAST => 8, :KRAT => 7, :KST => 9,
            
            :L => 11, :LHDT => 11, :LHST => 10.5, :LIGT => 10, :LINT => 14, :LKT => 6,
            :LST => 1,
            
            :M => 12, :MAGST => 12, :MAGT => 11, :MAL => 8, :MART => -9.5, :MAT => 3,
            :MAWT => 6, :MBT => 8, :MED => 2, :MEDST => 2, :MEST => 2, :MESZ => 2,
            :MET => 1, :MEWT => 1, :MEX => -6, :MEZ => 1, :MHT => 12, :MIT => 9.5,
            :MMT => 6.5, :MNT => 8, :MNST => 9, :MPT => 10, :MSD => 4, :MSK => 3,
            :MSKS => 4, :MT => 8.5, :MUT => 4, :MUST => 5, :MVT => 5, :MYT => 8,
            :MFPT => -10,
            
            :N => -1, :NCT => 11, :NDT => -2.5, :NFT => 11.5, :NOR => 1, :NOVST => 7,
            :NOVT => 6, :NPT => 5.75, :NRT => 12, :NST => -3.5, :NSUT => 6.5,
            :NT => -11, :NUT => -11, :NZDT => 13, :NZST => 12, :NZT => 12,
            
            :O => -2, :OESZ => 3, :OEZ => 2, :OMSK => 7, :OMSST => 7, :OMST => 6,
            
            :P => -3, :PET => -5, :PETST => 13, :PETT => 12, :PGT => 10, :PHOT => 13,
            :PHT => 8, :PIT => 8, :PKT => 5, :PKST => 6, :PMDT => -2, :PMST => -3,
            :PMT => -3, :PNT => -8.5, :PONT => 11, :PYST => -3, :PYT => -4, :PWT => 9,
            
            :Q => -4,
            
            :R => -5, :R1T => 2, :R2T => 3, :RET => 4, :ROK => 9, :ROTT => -3,
            
            :S => -6, :SADT => 10.5, :SAMST => 5, :SAMT => 4, :SAST => 2, :SBT => 11,
            :SCT => 4, :SCDT => 13, :SCST => 12, :SET => 1, :SGT => 8, :SIT => 8,
            :SLT => -4, :SLST => -3, :SRT => -3, :SST => -11, :SYST => 3, :SWT => 1,
            :SYT => 2,
            
            :T => -7, :TAHT => -10, :TFT => 5, :THA => 7, :THAT => -10, :TJT => 5,
            :TKT => -10, :TMT => 5, :TOT => 13, :TRUK => 10, :TPT => 9, :TRUT => 10,
            :TST => 3, :TUC => 0, :TVT => 12, :TWT => 8,
            
            :U => -8, :ULAST => 9, :ULAT => 8, :USZ1 => 2, :USZ1S => 3, :USZ3 => 4,
            :USZ3S => 5, :USZ4 => 5, :USZ4S => 6, :USZ5 => 6, :USZ5S => 7, :USZ6 => 7,
            :USZ6S => 8, :USZ7 => 8, :USZ7S => 9, :USZ8 => 9, :USZ8S => 10, :USZ9 => 10,
            :USZ9S => 11, :UTZ => -3, :UYT => -3, :UYST => -2, :UZ10 => 11, :UZ10S => 12,
            :UZ11 => 12, :UZ11S => 13, :UZ12 => 12, :UZ12S => 13, :UZT => 5,
            
            :V => -9, :VET => -4.5, :VLAST => 11, :VLAT => 10, :VOST => 6, :VST => -4.5,
            :VTZ => -2, :VUT => 11,
            
            :W => -10, :WAKT => 12, :WAST => 2, :WAT => 1, :WCT => 8.75, :WEST => 1,
            :WESZ => 1, :WET => 0, :WEZ => 0, :WFT => 12, :WGST => -2, :WGT => -3,
            :WIB => 7, :WITA => 8, :WIT => 9, :WST => 8, :WKST => 5, :WTZ => -1,
            :WUT => 1, :WEDT => 1, :WDT => 9,
            
            :X => -11,

            :Y => -12, :YAKST => 10, :YAKT => 9, :YAPT => 10, :YDT => -8, :YEKST => 6,
            :YEKT => 5, :YST => -9,

            :Z => 0         
          }  
          # unknown
          # :HL => X, :LST => X, :LT => X, :OZ => X :SZ => X :TAI => X :UT => X :WZ => X
          
          offset = (zone_offsets[timezone.to_s.upcase.to_sym] || 0) * seconds_in_hour
        end
      end
      return offset
    end
    
  end
end