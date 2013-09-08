module Barometer
  module Data
    class TypeRequiredWriter < Writer
      def coerce(value)
        if value.nil? || value.is_a?(primitive)
          super
        else
          raise ArgumentError
        end
      end
    end
  end
end
