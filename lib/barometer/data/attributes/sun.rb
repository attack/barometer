module Barometer
  module Data
    module Attribute
      class Sun < Virtus::Attribute
        def coerce(value)
          if value.nil?
            Barometer::Data::Sun.new
          elsif value.is_a?(Barometer::Data::Sun)
            value
          end
        end
      end
    end
  end
end
