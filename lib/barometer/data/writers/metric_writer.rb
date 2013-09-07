module Barometer
  module Data
    class MetricWriter < Writer
      def coerce(value)
        value = super

        if value.nil?
          primitive.new
        elsif value.is_a? primitive
          value
        else
          primitive.new(*value)
        end
      end

      def call(instance, value)
        value = super(instance, coerce(value))
        value.metric = instance.metric?
        value
      end
    end
  end
end
