require 'delegate'

module Barometer
  module WeatherService
    class Yahoo
      class Query < SimpleDelegator
        attr_reader :converted_query

        def self.accepted_formats
          [:zipcode, :weather_id, :woe_id]
        end

        def initialize(query)
          super
          @converted_query = convert_query
        end

        def to_param
          {u: unit_type}.merge(format_query)
        end

        private

        def convert_query
          convert!(*self.class.accepted_formats)
        end

        def format_query
          if converted_query.format == :woe_id
            { w: converted_query.q }
          else
            { p: converted_query.q }
          end
        end

        def unit_type
          converted_query.metric? ? 'c' : 'f'
        end
      end
    end
  end
end
