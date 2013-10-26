module Barometer
  module Data
    class Temperature < ConvertableUnits
      def c; metric; end
      def f; imperial; end

      def units
        metric? ? 'C' : 'F'
      end

      private

      def convert_imperial_to_metric(imperial_value)
        (5.0/9.0)*(imperial_value.to_f-32.0)
      end

      def convert_metric_to_imperial(metric_value)
        ((9.0/5.0)*metric_value.to_f)+32.0
      end
    end
  end
end
