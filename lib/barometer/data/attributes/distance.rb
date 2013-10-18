module Barometer
  module Data
    module Attribute
      class Distance < Virtus::Attribute
        def coerce(value)
          value.is_a?(Barometer::Data::Distance) ? value : Barometer::Data::Distance.new(*value)
        end
      end
    end
  end
end
