module Barometer
  module Data
    class Sun
      include Virtus.value_object

      attribute :rise, ::Time
      attribute :set, ::Time

      def nil?
        !(rise || set)
      end

      def after_rise?(time)
        time >= rise
      end

      def before_set?(time)
        time <= set
      end

      def to_s
        [_to_s('rise', rise), _to_s('set', set)].compact.join(', ')
      end

      private

      def _to_s(prefix, value)
        return unless value
        "#{prefix}: #{value.strftime('%H:%M')}"
      end
    end
  end
end
