module Barometer
  module Data
    class MetricReader < Reader
      def call(instance)
        value = super
        value.metric = instance.metric?
        value
      end
    end
  end
end
