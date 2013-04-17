module Barometer
  module Data
    class Distance < BasicUnits
      # METRIC_UNITS = "km"
      # IMPERIAL_UNITS = "m"

      # auto convert magnitude to_f (unless Int), degress to_i (unless Float)
      # convert incoming string to_i or to_f

      def initialize(*args)
        args = super(*args)
        parse_values!(args)
        freeze_all
      end

      def km; metric; end
      def m; imperial; end

      def units
        metric? ? 'km' : 'm'
      end

      private

      def convert_imperial_to_metric(imperial_value)
        imperial_value.to_f * 1.609
      end

      def convert_metric_to_imperial(metric_value)
        metric_value.to_f * 0.622
      end
    end
  end
end
