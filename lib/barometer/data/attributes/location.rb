module Barometer
  module Data
    module Attribute
      class Location < Virtus::Attribute::Object
        primitive Data::Location
        default primitive.new

        def self.writer_class(*)
          TypeRequiredWriter
        end
      end
    end
  end
end
