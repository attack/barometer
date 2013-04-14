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
  end
end
