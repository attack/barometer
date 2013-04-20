module Barometer
  #
  # NOAA Station ID
  # - this format cannot be detected, only set explictly
  #
  class Query::Format::NoaaStationId < Query::Format
    def self.regex; /!./; end
  end
end

Barometer::Formats.register(:noaa_station_id, Barometer::Query::Format::NoaaStationId)
