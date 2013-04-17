module Barometer
  module Data
    class Units
      include Comparable

      attr_accessor :metric

      def initialize(metric=true); @metric = metric; end
      def metric?; @metric; end
      def metric!; @metric=true; end
      def imperial!; @metric=false; end

      # assigns a value to the right attribute based on metric setting
      #
      def <<(value)
        return unless value

        nil_values = ["NA", "N/A", ""]

        begin
          if value.is_a?(Array)
            value_m = value[0].to_f if (value[0] && !nil_values.include?(value[0]))
            value_i = value[1].to_f if (value[1] && !nil_values.include?(value[1]))
            value_b = nil
          else
            value_m = nil
            value_i = nil
            value_b = value.to_f if (value && !nil_values.include?(value))
          end
        rescue
          # do nothing
        end

        self.metric? ? self.metric_default = value_m || value_b :
          self.imperial_default = value_i || value_b
      end

      def metric_default=(value); raise NotImplementedError; end
      def imperial_default=(value); raise NotImplementedError; end
    end

    class BasicUnits
      include Comparable

      def initialize(*args)
        parse_metric!(args)
        args
      end

      def metric=(value)
        if detect_imperial?(value)
          unknown_becomes_imperial!
          @metric = false
        else
          unknown_becomes_metric!
          @metric = true
        end
      end

      def metric?
        @metric.nil? || !!@metric
      end

      def to_i
        magnitude.to_i
      end

      def to_f
        magnitude.to_f
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
        metric_or_unknown || metric_from_imperial
      end

      def imperial
        imperial_or_unknown || imperial_from_metric
      end

      private

      def metric_from_imperial
        return nil unless imperial_or_unknown
        round(convert_imperial_to_metric(imperial_or_unknown))
      end

      def convert_imperial_to_metric(value)
        value
      end

      def imperial_from_metric
        return nil unless metric_or_unknown
        round(convert_metric_to_imperial(metric_or_unknown))
      end

      def magnitude
        metric? ? metric : imperial
      end

      def parse_metric!(args)
        unless detect_number?(args.first)
          self.metric = args.shift
        end
      end

      def parse_values!(args)
        parse_extra_values!(args)

        if args.length == 1
          self.unknown = args.shift
        else
          @metric_value = args.shift
          @imperial_value = args.shift
        end
      end

      def parse_extra_values!(args)
        args
      end

      def unknown=(value)
        if @metric.nil?
          @unknown = value
        elsif metric?
          @metric_value = value
        else
          @imperial_value = value
        end
        freeze_magnitude
      end

      def unknown_becomes_imperial!
        if @unknown && !@imperial_value
          @imperial_value = @unknown
          @unknown = nil
        end
      end

      def unknown_becomes_metric!
        if @unknown && !@metric_value
          @metric_value = @unknown
          @unknown = nil
        end
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

      def metric_or_unknown
        @metric_value || metric_unknown
      end

      def imperial_or_unknown
        @imperial_value || imperial_unknown
      end

      def metric_unknown
        @unknown if metric?
      end

      def imperial_unknown
        @unknown unless metric?
      end

      def round(number)
        (10*number.to_f).round/10.0
      end

      def magnitude_to_s
        "#{magnitude} #{units}" unless magnitude.nil?
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
      end
    end
  end
end
