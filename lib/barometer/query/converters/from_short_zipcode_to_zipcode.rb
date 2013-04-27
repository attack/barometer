module Barometer
  module Query
    module Converter
      class FromShortZipcodeToZipcode
        def self.from
          [:short_zipcode]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?
          @query.add_conversion(:zipcode, @query.get_conversion(:short_zipcode).q)
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:zipcode, Barometer::Query::Converter::FromShortZipcodeToZipcode)
