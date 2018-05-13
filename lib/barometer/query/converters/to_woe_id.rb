module Barometer
  module Query
    module Converter
      class ToWoeId
        def self.from
          [:short_zipcode, :geocode, :unknown, :coordinates, :postalcode]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          woe_id = Service::ToWoeId.new(@query).call
          @query.add_conversion(:woe_id, woe_id)
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:woe_id, Barometer::Query::Converter::ToWoeId)
