module Barometer
  module Data
    module Attribute
      class Time < Virtus::Attribute::Object
        primitive ::Time
        default nil

        def self.writer_class(*)
          TimeWriter
        end
      end
    end
  end
end
