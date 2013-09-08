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

require 'barometer/data/writers/metric_writer.rb'
require 'barometer/data/writers/type_required_writer.rb'
require 'barometer/data/writers/time_writer.rb'
require 'barometer/data/writers/float_writer.rb'
require 'barometer/data/writers/integer_writer.rb'
