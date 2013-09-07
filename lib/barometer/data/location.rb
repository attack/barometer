require 'virtus'

module Barometer
  module Data
    class Location
      include Virtus::ValueObject

      attribute :id, String
      attribute :name, String
      attribute :city, String
      attribute :state_name, String
      attribute :state_code, String
      attribute :country, String
      attribute :country_code, String
      attribute :zip_code, String
      attribute :latitude, Data::Attribute::Float
      attribute :longitude, Data::Attribute::Float

      def coordinates
        [latitude, longitude].join(',')
      end

      def to_s
        [name, city, state_name || state_code,
          country || country_code].compact.join(', ')
      end
    end
  end
end
