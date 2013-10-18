module Barometer
  module Data
    module Attribute
      class Vector < Virtus::Attribute
        def coerce(value)
          value.is_a?(Barometer::Data::Vector) ? value : Barometer::Data::Vector.new(*value)
        end
      end
    end
  end
end
