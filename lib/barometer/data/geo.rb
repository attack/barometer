module Barometer
  module Data
    class Geo
      attr_accessor :latitude, :longitude, :query
      attr_accessor :locality, :region, :country, :country_code, :address, :postal_code

      def coordinates
        [@latitude, @longitude].join(',')
      end

      def to_s
        s = [@address, @locality, @region, @country || @country_code]
        s.delete("")
        s.compact.join(', ')
      end
    end
  end
end
