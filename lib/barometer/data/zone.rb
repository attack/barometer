require 'tzinfo'

module Barometer
  module Data
    #
    # A simple Zone class
    #
    # Used for building and converting timezone aware date and times
    # Really, these are just wrappers for TZInfo conversions plus
    # some extras.
    #
    class Zone

      @@zone_codes_file = File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'translations', 'zone_codes.yml'))
      @@zone_codes = nil

      attr_accessor :zone_full, :zone_code, :zone_offset, :tz

      def initialize(zone)
        if Data::Zone.is_zone_full?(zone)
          @zone_full = zone
          @tz = TZInfo::Timezone.get(zone)
        elsif Data::Zone.is_zone_offset?(zone)
          @zone_offset = zone
        elsif Data::Zone.is_zone_code?(zone)
          @zone_code = zone
        else
          raise(ArgumentError, "invalid time zone")
        end
      end

      def current
        @zone_full || @zone_offset || @zone_code
      end

      # what is the Timezone Short Code for the current timezone
      def code
        return @zone_code if @zone_code
        return nil unless @tz
        @tz.period_for_utc(Time.now.utc).zone_identifier.to_s
      end

      def full
        @zone_full || nil
      end

      def offset
        if @zone_offset
          @zone_offset.to_f * 60 * 60
        elsif @zone_code
          Data::Zone.zone_to_offset(@zone_code)
        elsif @zone_full
        end
      end

      # is the current timezone in daylights savings mode?
      def dst?
        return nil unless @tz
        @tz.period_for_utc(::Time.now.utc).dst?
      end

      # return Time.now.utc for the set timezone
      def now
        if @zone_full
          now = @tz.utc_to_local(Time.now.utc)
        elsif @zone_offset || @zone_code
          now = Time.now.utc + self.offset
        end
        now
      end

      # return Date.today for the set timezone
      def today
        now = self.now
        Date.new(now.year, now.month, now.day)
      end

      def local_to_utc(local_time)
        if @zone_full
          @tz.local_to_utc(local_time)
        elsif @zone_offset || @zone_code
          local_time -= self.offset
          Time.utc(local_time.year,local_time.month,local_time.day,
            local_time.hour,local_time.min,local_time.sec)
        end
      end

      def utc_to_local(utc_time)
        if @zone_full
          @tz.utc_to_local(utc_time)
        elsif @zone_offset || @zone_code
          utc_time + self.offset
        end
      end

      #
      # Class Methods
      #

      def self.is_zone_code?(zone)
        return false unless (zone && zone.is_a?(String))
        _load_zone_codes unless @@zone_codes
        Time.zone_offset(zone) || (@@zone_codes && @@zone_codes.has_key?(zone))
      end

      def self.is_zone_full?(zone)
        return false unless (zone && zone.is_a?(String))
        zone.match(/[A-Za-z]+\/[A-Za-z]+/) ? true : false
      end

      def self.is_zone_offset?(zone)
        return false unless (zone && (zone.is_a?(Fixnum) || zone.is_a?(Float)))
        zone.to_f.abs <= 14
      end

      #
      # Known conflicts
      # IRT (ireland and india)
      # CST (central standard time, china standard time)
      #
      def self.zone_to_offset(timezone)
        offset = 0
        seconds_in_hour = 60*60
        # try to use Time
        unless offset = Time.zone_offset(timezone)
          # that would have been too easy, do it manually
          # http://www.timeanddate.com/library/abbreviations/timezones/
          # http://www.worldtimezone.com/wtz-names/timezonenames.html
          offset = (@@zone_codes[timezone.to_s.upcase] || 0) * seconds_in_hour
        end
        offset
      end

      def self._load_zone_codes
        $:.unshift(File.dirname(__FILE__))
        @@zone_codes ||= YAML.load_file(@@zone_codes_file)
      end

    end
  end
end
