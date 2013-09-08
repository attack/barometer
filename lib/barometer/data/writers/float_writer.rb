module Barometer
  module Data
    class FloatWriter < Writer
      def coerce(value)
        value ? value.to_f : default_value.call
      end
    end
  end
end
