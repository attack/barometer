module Barometer
  module Data
    module Attribute
      class Zone < Virtus::Attribute::Object
        primitive Data::Zone
        default nil

        class Zone < Virtus::Attribute::Writer::Coercible
          def coerce(value)
            if value.nil? || value.is_a?(primitive)
              super
            else
              primitive.new(super)
            end
          end
        end

        def self.writer_class(*)
          Zone
        end
      end
    end
  end
end
