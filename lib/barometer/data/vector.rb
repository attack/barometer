module Barometer
  module Data
    class Vector < ConvertableUnits
      # METRIC_UNITS = "kph"
      # IMPERIAL_UNITS = "mph"

      attr_reader :bearing

      def initialize(*args)
        args = super(*args)
        parse_values!(args)
        freeze_all
      end

      def kph; metric; end
      def mph; imperial; end

      def units
        metric? ? 'kph' : 'mph'
      end

      def to_s
        [magnitude_to_s, bearing_to_s].compact.join(' @ ')
      end

      def nil?
        magnitude.nil? && bearing.nil?
      end

      private

      def convert_imperial_to_metric(imperial_value)
        imperial_value.to_f * 1.609
      end

      def convert_metric_to_imperial(metric_value)
        metric_value.to_f * 0.622
      end

      def parse_extra_values!(args)
        @bearing = args.pop if args.size > 1
      end

      def bearing_to_s
        "#{bearing} degrees" unless bearing.nil?
      end

      def freeze_extra
        @bearing.freeze
      end
    end
  end
end
