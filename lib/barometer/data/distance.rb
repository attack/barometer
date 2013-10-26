module Barometer
  module Data
    class Distance < ConvertableUnits
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
