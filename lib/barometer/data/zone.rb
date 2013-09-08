require 'tzinfo'
require 'delegate'

module Barometer
  module Data
    class Zone < SimpleDelegator
      def initialize(zone)
        zone = if ZoneFull.detect?(zone)
          ZoneFull.new(zone)
        elsif ZoneOffset.detect?(zone)
          ZoneOffset.new(zone)
        elsif ZoneCode.detect?(zone)
          ZoneCode.new(zone)
        else
          raise(ArgumentError, "invalid time zone")
        end
        super(zone)
      end
    end

    class ZoneFull
      def self.detect?(zone)
        zone.respond_to?(:match) && !!zone.match(/^[A-Za-z]+\/[A-Za-z_]+$/)
      end

      def initialize(zone, time_class=::Time)
        @zone = zone
        @time_class = time_class
        @tz = TZInfo::Timezone.get(zone)
      end

      def code
        tz.period_for_utc(time_class.now.utc).zone_identifier.to_s
      end

      def offset
        tz.period_for_utc(time_class.now.utc).utc_total_offset
      end

      def now
        tz.utc_to_local(time_class.now.utc)
      end

      def to_s
        zone
      end

      def local_to_utc(local_time)
        tz.local_to_utc(local_time)
      end

      def utc_to_local(utc_time)
        tz.utc_to_local(utc_time)
      end

      private

      attr_reader :zone, :tz, :time_class
    end

    class ZoneOffset
      def self.detect?(zone)
        zone.respond_to?(:abs) && zone.abs <= 14
      end

      def initialize(zone, time_class=::Time)
        @zone = zone
        @time_class = time_class
      end

      def code
      end

      def offset
        zone.to_f * 60 * 60
      end

      def now
        time_class.now.utc + offset
      end

      def to_s
        zone.to_s
      end

      def local_to_utc(local_time)
        local_time - offset
      end

      def utc_to_local(utc_time)
        utc_time + offset
      end

      private

      attr_reader :zone, :time_class
    end

    class ZoneCode
      def self.detect?(zone)
        zone.respond_to?(:to_s) && Utils::ZoneCodeLookup.exists?(zone.to_s)
      end

      def initialize(zone, time_class=::Time)
        @zone = zone
        @time_class = time_class
      end

      def code
        zone
      end

      def offset
        Utils::ZoneCodeLookup.offset(zone)
      end

      def now
        time_class.now.utc + offset
      end

      def to_s
        zone
      end

      def local_to_utc(local_time)
        local_time - offset
      end

      def utc_to_local(utc_time)
        utc_time + offset
      end

      private

      attr_reader :zone, :time_class
    end
  end
end
