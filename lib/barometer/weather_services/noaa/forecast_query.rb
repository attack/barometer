require 'delegate'

module Barometer
  module WeatherService
    class Noaa
      class ForecastQuery < SimpleDelegator
        attr_reader :converted_query

        def self.accepted_formats
          [:zipcode, :coordinates]
        end

        def initialize(query)
          super
          @converted_query = convert_query
        end

        def to_param
          {:format => '24 hourly', :numDays => '7'}.merge(format_query)
        end

        private

        def convert_query
          convert!(*self.class.accepted_formats)
        end

        def format_query
          case converted_query.format.to_sym
          when :short_zipcode
            {:zipCodeList => converted_query.q}
          when :zipcode
            {:zipCodeList => converted_query.q}
          when :coordinates
            {:lat => converted_query.q.split(',')[0], :lon => converted_query.q.split(',')[1]}
          else
            {}
          end
        end
      end
    end
  end
end
