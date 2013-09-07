module Barometer
  module Data
    class IntegerWriter < Writer
      def coerce(value)
        value ? value.to_i : default_value.call
      end
    end
  end
end
