module Barometer
  module Data
    module Attribute
      class Zone < Virtus::Attribute
        def coerce(value)
          value.nil? || value.is_a?(Barometer::Data::Zone) ? value : raise(ArgumentError)
        end
      end
    end
  end
end
