module Barometer
  module Data
    module Attribute
      class Time < Virtus::Attribute
        def coerce(value)
          value.nil? || value.is_a?(::Time) ? value : Utils::Time.parse(*value)
        end
      end
    end
  end
end
