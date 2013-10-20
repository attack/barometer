module Barometer
  module Utils
    module Time
      def self.parse(*args)
        return unless args.compact.size > 0

        if args.first.is_a? ::Time
          args.first
        elsif args.first.is_a? DateTime
          ::Time.parse(args.first.to_s)
        elsif args.first.respond_to?(:to_time)
          args.first.to_time
        elsif args.size == 1 || args.size == 2
          strptime(*args)
        else
          ::Time.utc(*args)
        end
      end

      def self.strftime(time)
        time.strftime("%Y-%m-%d %H:%M:%S %z")
      end

      def self.strptime(str, format=nil)
        dt = if format
          DateTime.strptime(str, format)
        else
          DateTime.parse(str)
        end
        ::Time.utc(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec) - (dt.zone.to_f * 60 * 60)
      end

      def self.utc_from_base_plus_local_time(tz, base, hour, min)
        return unless tz && base
        local_base = tz.utc_to_local(base.utc)

        local_time = ::Time.utc(local_base.year, local_base.month, local_base.day, hour, min, 0)
        tz.local_to_utc(local_time)
      end

      def self.utc_merge_base_plus_time(base_time=nil, time=nil)
        return unless base_time && time
        base_time_utc = base_time.utc
        time_utc = time.utc

        ::Time.utc(
          base_time_utc.year, base_time_utc.month, base_time_utc.day,
          time_utc.hour, time_utc.min, 0
        )
      end

      def self.add_one_day(time)
        return unless time
        one_day_minus_one_second = (60 * 60 * 24 - 1)
        time + one_day_minus_one_second
      end

      def self.add_one_hour(time)
        return unless time
        one_hour = (60 * 60 * 1)
        time + one_hour
      end
    end
  end
end
