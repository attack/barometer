require_relative 'apis/yahoo'

module Barometer
  module Query
    module Service
      class ToWoeId
        def initialize(query)
          @query = query
        end

        def call
          converted_query = query.get_conversion(:short_zipcode, :geocode, :unknown, :coordinates, :postalcode)
          return unless converted_query

          @payload = Yahoo::Api.new(converted_query).get
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
