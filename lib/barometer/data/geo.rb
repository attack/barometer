require 'virtus'

module Barometer
  module Data
    class Geo
      include Virtus.model

      attribute :latitude, Float
      attribute :longitude, Float
      attribute :query, String
      attribute :address, String
      attribute :locality, String
      attribute :region, String
      attribute :country, String
      attribute :country_code, String
      attribute :postal_code, String

      def coordinates
        [latitude, longitude].join(',')
      end

      def to_s
        [address, locality, region, country || country_code].
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
        self.send("#{attr}=", value) if self.send(attr).nil?
      end
    end
  end
end
