module Barometer
  module Query
    module Format
      #
      # NOAA Station ID
      # - this format cannot be detected, only set explictly
      #
      class NoaaStationId < Base
        def self.is?(query); false; end
      end
    end
  end
end

Barometer::Query::Format.register(:noaa_station_id, Barometer::Query::Format::NoaaStationId)
