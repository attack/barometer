module Barometer
  module Utils
    module Time
      def self.parse(*args)
        return unless args.compact.size > 0
        first_arg = args.first

        if first_arg.is_a? ::Time
          first_arg
        elsif first_arg.is_a?(::DateTime) || first_arg.is_a?(::Date)
          ::Time.parse(first_arg.to_s)
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
          ::DateTime.strptime(str, format)
        else
          ::DateTime.parse(str)
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

      def self.start_of_day(time)
        ::Time.utc(
          time.year, time.month, time.day,
          0, 0, 0
        )
      end

      def self.end_of_day(time)
        ::Time.utc(
          time.year, time.month, time.day,
          23, 59, 59
        )
      end
    end
  end
end
