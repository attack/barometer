require 'virtus'

module Barometer
  module Data
    class Coordinates
      include Virtus.value_object

      attribute :latitude, Float
      attribute :longitude, Float

      def coordinates
        [latitude, longitude].join(',')
      end
    end
  end
end
