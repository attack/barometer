require 'virtus'

module Barometer
  module Data
    class Writer < Virtus::Attribute::Writer::Coercible
      def coerce(value)
        super
      end
    end
  end
end

require 'barometer/data/writers/float_writer.rb'
