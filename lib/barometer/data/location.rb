module Barometer
  module Data
    class Location < Coordinates
      attribute :id, String
      attribute :name, String
      attribute :city, String
      attribute :state_name, String
      attribute :state_code, String
      attribute :country, String
      attribute :country_code, String
      attribute :zip_code, String

      def to_s
        [name, city, state_name || state_code,
          country || country_code].compact.join(', ')
      end
    end
  end
end
