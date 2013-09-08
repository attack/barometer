module Barometer
  module Data
    module Attribute
      class Float < Virtus::Attribute::Object
        def self.writer_class(*args)
          FloatWriter
        end
      end
    end
  end
end
