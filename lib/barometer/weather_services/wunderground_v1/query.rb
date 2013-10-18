require 'delegate'

module Barometer
  module WeatherService
    class WundergroundV1
      class Query < SimpleDelegator
        attr_reader :converted_query

        def self.accepted_formats
          [:zipcode, :postalcode, :icao, :coordinates, :geocode]
        end

        def initialize(query)
          super
          @converted_query = convert_query
        end

        def to_param
          {query: converted_query.q.dup}
        end

        private

        def convert_query
          convert!(*self.class.accepted_formats)
        end
      end
    end
  end
end
