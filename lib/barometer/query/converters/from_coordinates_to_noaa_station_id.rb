module Barometer
  module Query
    module Converter
      class FromCoordinatesToNoaaStationId
        def self.from
          [:coordinates]
        end

        def initialize(query)
          @query = query
        end

        def call
          return unless can_convert?

          station_id = Service::NoaaStation.fetch(@query)
          @query.add_conversion(:noaa_station_id, station_id)
        end

        private

        def can_convert?
          !!@query.get_conversion(*self.class.from)
        end
      end
    end
  end
end

Barometer::Query::Converter.register(:noaa_station_id, Barometer::Query::Converter::FromCoordinatesToNoaaStationId)
