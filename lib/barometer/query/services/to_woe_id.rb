require_relative 'apis/yahoo_placefinder'

module Barometer
  module Query
    module Service
      class ToWoeId
        def initialize(query)
          @query = query
        end

        def call
          converted_query = query.get_conversion(:short_zipcode, :zipcode, :geocode, :unknown, :coordinates, :postalcode, :ipv4_address)
          return unless converted_query

          @payload = YahooPlacefinder::Api.new(converted_query).get
          parse_payload
        end

        private

        attr_reader :query, :payload

        def parse_payload
          payload.fetch('woeid')
        end
      end
    end
  end
end
