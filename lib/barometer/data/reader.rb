require 'virtus'

module Barometer
  module Data
    class Reader < Virtus::Attribute::Reader
      def call(instance)
        super
      end
    end
  end
end

require 'barometer/data/readers/metric_reader.rb'
