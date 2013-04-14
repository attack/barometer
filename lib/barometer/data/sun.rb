module Barometer
  module Data
    class Sun
      attr_reader :rise, :set

      def initialize(rise=nil, set=nil)
        raise ArgumentError unless (rise.is_a?(Data::LocalTime) || rise.nil?)
        raise ArgumentError unless (set.is_a?(Data::LocalTime) || set.nil?)
        @rise = rise
        @set = set
      end

      def rise=(time)
        raise ArgumentError unless (time.is_a?(Data::LocalTime) || time.nil?)
        @rise = time
      end

      def set=(time)
        raise ArgumentError unless (time.is_a?(Data::LocalTime) || time.nil?)
        @set = time
      end

      def nil?
        !(@rise || @set)
      end

      def after_rise?(time)
        raise ArgumentError unless time.is_a?(Data::LocalTime)
        time >= @rise
      end

      def before_set?(time)
        raise ArgumentError unless time.is_a?(Data::LocalTime)
        time <= @set
      end

      def to_s
        output = []
        output << "rise: #{rise}" if rise
        output << "set: #{set}" if set
        output.join(', ')
      end
    end
  end
end
