module Barometer
  #
  # eg. 123 Elm St, Mystery, Alaska, USA
  #
  class Query::Format::Geocode < Query::Format
    def self.is?(query); true; end
  end
end

Barometer::Formats.register(:geocode, Barometer::Query::Format::Geocode)
