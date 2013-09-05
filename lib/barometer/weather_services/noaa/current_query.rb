require 'delegate'

module Barometer
  module WeatherService
    class Noaa
      class CurrentQuery < SimpleDelegator
        attr_reader :converted_query

        def self.accepted_formats
          [:noaa_station_id]
        end

        def initialize(query)
          super
          @converted_query = convert_query
        end

        def to_param
          converted_query.q
        end

        private

        def convert_query
          convert!(*self.class.accepted_formats)
        end
      end
    end
  end
end
