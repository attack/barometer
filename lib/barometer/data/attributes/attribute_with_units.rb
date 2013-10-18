module Barometer
  module Data
    module Attribute
      class AttributeWithUnits < Virtus::Attribute::Object
        default nil

        def self.writer_class(*args)
          MetricWriter
        end
      end
    end
  end
end
