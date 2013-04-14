module Barometer
  module Data
    class Vector #< Units
      include Comparable
      # METRIC_UNITS = "kph"
      # IMPERIAL_UNITS = "mph"

      # auto convert magnitude to_f (unless Int), degress to_i (unless Float)
      # add compass direction output

      attr_reader :bearing

      def initialize(*args)
        parse_metric!(args)
        parse_values!(args)
        freeze_all
      end

      def kph
        kph_or_unknown || kph_from_mph
      end

      def mph
        mph_or_unknown || mph_from_kph
      end

      def units
        metric? ? 'kph' : 'mph'
      end

      def metric?
        @metric.nil? || !!@metric
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

      def to_i
        magnitude.to_i
      end

      def to_f
        magnitude.to_f
      end

      def to_s
        [magnitude_to_s, bearing_to_s].compact.join(' @ ')
      end

      def nil?
        magnitude.nil? && bearing.nil?
      end

      def <=>(other)
        kph.to_f <=> other.kph.to_f
      end

      private

      def parse_metric!(args)
        unless detect_number?(args.first)
          self.metric = args.shift
        end
      end

      def parse_values!(args)
        if args.length == 3
          @kph = args[0]
          @mph = args[1]
          @bearing = args[2]
        else
          self.unknown = args[0]
          @bearing = args[1]
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

      def unknown=(value)
        if @metric.nil?
          @unknown = value
        elsif metric?
          @kph = value
        else
          @mph = value
        end
        freeze_magnitude
      end

      def kph_or_unknown
        @kph || metric_unknown
      end

      def mph_or_unknown
        @mph || imperial_unknown
      end

      def metric_unknown
        @unknown if metric?
      end

      def imperial_unknown
        @unknown unless metric?
      end

      def unknown_becomes_imperial!
        if @unknown && !@mph
          @mph = @unknown
          @unknown = nil
        end
      end

      def unknown_becomes_metric!
        if @unknown && !@kph
          @kph = @unknown
          @unknown = nil
        end
      end

      def magnitude
        metric? ? kph : mph
      end

      def kph_from_mph
        return nil unless mph_or_unknown
        round(mph_or_unknown.to_f * 1.609)
      end

      def mph_from_kph
        return nil unless kph_or_unknown
        round(kph_or_unknown.to_f * 0.622)
      end

      def round(number)
        (10*number).round/10.0
      end

      def magnitude_to_s
        "#{magnitude} #{units}" unless magnitude.nil?
      end

      def bearing_to_s
        "#{bearing} degrees" unless bearing.nil?
      end

      def freeze_all
        freeze_magnitude
        @bearing.freeze
      end

      def freeze_magnitude
        @kph.freeze
        @mph.freeze
      end
    end
  end
end
