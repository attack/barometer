module Barometer
  module Data
    module Attribute
      class Location < Virtus::Attribute::Object
        primitive Data::Location
        default primitive.new

        class Location < Virtus::Attribute::Writer::Coercible
          def coerce(value)
            if value.nil? || value.is_a?(primitive)
              super
            else
              raise ArgumentError
            end
          end
        end

        def self.writer_class(*)
          Location
        end
      end
    end
  end
end
