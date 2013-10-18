module Barometer
  module Data
    module Attribute
      class Location < Virtus::Attribute
        def coerce(value)
          value.is_a?(Barometer::Data::Location) ? value : Barometer::Data::Location.new(*value)
        end
      end
    end
  end
end
