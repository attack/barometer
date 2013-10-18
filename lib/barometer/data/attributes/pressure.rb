module Barometer
  module Data
    module Attribute
      class Pressure < Virtus::Attribute
        def coerce(value)
          value.is_a?(Barometer::Data::Pressure) ? value : Barometer::Data::Pressure.new(*value)
        end
      end
    end
  end
end
