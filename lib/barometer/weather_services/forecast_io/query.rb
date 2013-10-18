require 'delegate'

module Barometer
  module WeatherService
    class ForecastIo
      class Query < SimpleDelegator
        attr_reader :converted_query

        def self.accepted_formats
          [:coordinates]
        end

        def initialize(query)
          super
          @converted_query = convert_query
        end

        def to_param
          @converted_query.q
        end

        def units_param
          {units: unit_type}
        end

        private

        def convert_query
          convert!(*self.class.accepted_formats)
        end

        def unit_type
          converted_query.metric? ? 'si' : 'us'
        end
      end
    end
  end
end
