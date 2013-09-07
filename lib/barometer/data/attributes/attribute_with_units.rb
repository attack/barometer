module Barometer
  module Data
    module Attribute
      class AttributeWithUnits < Virtus::Attribute::Object
        default nil

        def self.writer_class(*args)
          MetricWriter
        end

        def self.reader_class(*args)
          MetricReader
        end
      end
    end
  end
end
