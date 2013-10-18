module Barometer
  module Data
    module Attribute
      class Temperature < Virtus::Attribute
        def coerce(value, *args)
          value.is_a?(Barometer::Data::Temperature) ? value : Barometer::Data::Temperature.new(*value)
        end
      end
    end
  end
end
