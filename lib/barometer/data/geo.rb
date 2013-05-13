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

      def merge(geo)
        return unless geo.is_a?(Barometer::Data::Geo)

        %w(
          locality region country country_code postal_code
          query address latitude longitude
        ).each do |attr|
          set_if_nil(attr, geo.send(attr))
        end
      end

      private

      def set_if_nil(attr, value)
        if instance_variable_get("@#{attr}").nil?
          instance_variable_set("@#{attr}", value)
        end
      end
    end
  end
end
