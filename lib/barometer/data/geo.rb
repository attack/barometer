require 'virtus'

module Barometer
  module Data
    class Geo
      include Virtus
      include Utils::DataTypes

      attribute :query, String
      attribute :address, String
      attribute :locality, String
      attribute :region, String
      attribute :country, String
      attribute :country_code, String
      attribute :postal_code, String

      float :latitude, :longitude

      def coordinates
        [@latitude, @longitude].join(',')
      end

      def to_s
        [@address, @locality, @region, @country || @country_code].
          compact.reject(&:empty?).join(', ')
      end

      def merge(geo)
        return unless geo.is_a?(Geo)

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
