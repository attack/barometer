module Barometer
  module Data
    class Sun
      include Virtus::ValueObject

      attribute :rise, ::Time
      attribute :set, ::Time

      def initialize(rise=nil, set=nil)
        raise ArgumentError unless (rise.is_a?(Time) || rise.nil?)
        raise ArgumentError unless (set.is_a?(Time) || set.nil?)
        self.rise = rise
        self.set = set
      end

      def nil?
        !(rise || set)
      end

      def after_rise?(time)
        raise ArgumentError unless time.is_a?(Time)
        time >= rise
      end

      def before_set?(time)
        raise ArgumentError unless time.is_a?(Time)
        time <= set
      end

      def to_s
        output = []
        output << "rise: #{rise.strftime("%H:%M")}" if rise
        output << "set: #{set.strftime("%H:%M")}" if set
        output.join(', ')
      end
    end
  end
end
