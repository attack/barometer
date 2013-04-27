module Barometer
  module Data
    class Geo
      attr_accessor :latitude, :longitude, :query
      attr_accessor :locality, :region, :country, :country_code, :address

      def initialize(location=nil)
        return unless location
        raise ArgumentError unless location.is_a?(Hash)
        self.build_from_hash(location)
      end

      def build_from_hash(location=nil)
        return nil unless location
        raise ArgumentError unless location.is_a?(Hash)

        payload = Utils::Payload.new(location)

        @latitude = payload.fetch("geometry", "location", "lat").to_f
        @longitude = payload.fetch("geometry", "location", "lng").to_f

        query_parts = []
        if location["address_components"]
          location["address_components"].each do |address_components|
            skip unless address_components["types"]
            # sublocality trumps locality
            if address_components["types"].include?('sublocality')
              @locality = address_components["long_name"]
            end
            if address_components["types"].include?('locality')
              @locality ||= address_components["long_name"]
            end
            if address_components["types"].include?('administrative_area_level_1')
              #@region = address_components["long_name"]
              @region = address_components["short_name"]
            end
            if address_components["types"].include?('country')
              @country = address_components["long_name"]
              @country_code = address_components["short_name"]
            end
            if !(address_components["types"] & location["types"]).empty?
              query_parts << address_components["long_name"]
            end
          end
        end

        @query = query_parts.join(', ')
        @address = ""
      end

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
