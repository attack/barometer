require 'delegate'

module Barometer
  module Data
    class ConvertableUnits < SimpleDelegator
      include Comparable

      def initialize(*args)
        parse_metric!(args)
        parse_values!(args)
        super(magnitude)
        freeze_all
      end

      def to_s
        magnitude_to_s
      end

      def nil?
        magnitude.nil?
      end

      def <=>(other)
        round(metric) <=> round(other.metric)
      end

      def metric
        @metric_value || metric_from_imperial
      end

      def imperial
        @imperial_value || imperial_from_metric
      end

      def units
        metric? ? 'METRIC' : 'IMPERIAL'
      end

      def metric?
        !!@metric
      end

      private

      def metric=(value)
        if detect_imperial?(value)
          @metric = false
        else
          @metric = true
        end
      end

      def metric_from_imperial
        return unless @imperial_value
        round(convert_imperial_to_metric(@imperial_value))
      end

      def convert_imperial_to_metric(value)
        value
      end

      def imperial_from_metric
        return unless @metric_value
        round(convert_metric_to_imperial(@metric_value))
      end

      def magnitude
        metric? ? metric : imperial
      end

      def parse_metric!(args)
        unless detect_number?(args.first)
          self.metric = args.shift
        else
          self.metric = true
        end
      end

      def parse_values!(args)
        parse_extra_values!(args)

        if args.length == 1
          parse_single_value!(args.shift)
        else
          parse_multiple_values!(args)
        end
        freeze_magnitude
      end

      def parse_extra_values!(args)
        args
      end

      def parse_single_value!(value)
        if metric?
          @metric_value = value
        else
          @imperial_value = value
        end
      end

      def parse_multiple_values!(values)
        @metric_value = values.shift
        @imperial_value = values.shift
      end

      def detect_imperial?(value)
        value == :imperial || value.is_a?(FalseClass)
      end

      def detect_number?(value)
        value.nil? || value.is_a?(Numeric) || string_is_number?(value)
      end

      def string_is_number?(value)
        value.is_a?(String) &&
          ((value.to_i.to_s == value) || (value.to_f.to_s == value))
      end

      def round(number)
        (10*number.to_f).round/10.0
      end

      def magnitude_to_s
        return if magnitude.nil?
        "#{magnitude} #{units}"
      end

      def freeze_all
        freeze_magnitude
        freeze_extra
      end

      def freeze_extra
        nil
      end

      def freeze_magnitude
        @metric_value.freeze
        @imperial_value.freeze
        @metric.freeze
      end
    end
  end
end
