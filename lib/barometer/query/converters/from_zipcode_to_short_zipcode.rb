module Barometer
  module Query
    module Converter
      class FromZipcodeToShortZipcode
        def self.from
          [:zipcode]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?
          @query.add_conversion(
            :short_zipcode,
            @query.get_conversion(:zipcode).q[0..4]
          )
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:short_zipcode, Barometer::Query::Converter::FromZipcodeToShortZipcode)
