module Barometer
  module Data
    class TimeWriter < Writer
      def coerce(value)
        if value.nil?
          super
        elsif value.is_a? primitive
          value
        else
          Utils::Time.parse(*value)
        end
      end
    end
  end
end
