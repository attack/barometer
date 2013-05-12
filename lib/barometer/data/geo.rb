module Barometer
  module Data
    class Geo
      include Barometer::Utils::DataTypes

      float :latitude, :longitude
      string :query, :address
      string :locality, :region, :country, :country_code, :postal_code

      def coordinates
        [@latitude, @longitude].join(',')
      end

      def to_s
        [@address, @locality, @region, @country || @country_code].
          compact.reject(&:empty?).join(', ')
      end
    end
  end
end
