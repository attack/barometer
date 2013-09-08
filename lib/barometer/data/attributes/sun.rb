module Barometer
  module Data
    module Attribute
      class Sun < Virtus::Attribute::Object
        primitive Data::Sun
        default primitive.new

        def self.writer_class(*)
          TypeRequiredWriter
        end
      end
    end
  end
end
