module Barometer
  module Data
    module Attribute
      class Integer < Virtus::Attribute
        def coerce(value, *args)
          value ? value.to_i : default_value.call
        end
      end
    end
  end
end
