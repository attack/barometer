module Barometer
  module Query
    module Converter
      class ToWeatherId
        def self.from
          [:geocode, :unknown]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          weather_id = Service::ToWeatherId.call(@query)
          @query.add_conversion(:weather_id, weather_id)
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:weather_id, Barometer::Query::Converter::ToWeatherId)
