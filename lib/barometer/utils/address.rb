require 'addressable/uri'

module Barometer
  module Utils
    class Address
      def initialize(url, query={})
        @address = Addressable::URI.parse(url)
        add(query) unless query.blank?
      end

      def query
        address.query_values
      end

      def url
        address.omit(:query).to_s
      end

      def add(addition)
        current_values = address.query_values || {}
        address.query_values = current_values.merge(addition)
      end

      def to_s
        address.to_s
      end

      private

      attr_reader :address
    end
  end
end
