require 'delegate'

module Barometer
  module WeatherService
    class WeatherBug
      class Query < SimpleDelegator
        attr_reader :converted_query

        def self.accepted_formats
          [:short_zipcode, :coordinates]
        end

        def initialize(query)
          super
          @converted_query = convert_query
        end

        def to_param
          {UnitType: unit_type}.merge(format_query)
        end

        private

        def convert_query
          convert!(*self.class.accepted_formats)
        end

        def format_query
          if converted_query.format == :short_zipcode
            {zipCode: converted_query.q}
          else
            {lat: converted_query.latitude, long: converted_query.longitude}
          end
        end

        def unit_type
          converted_query.metric? ? '1' : '0'
        end
      end
    end
  end
end
