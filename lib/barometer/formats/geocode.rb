module Barometer
  #
  # Format: Geocode
  # (not to be confused with the WebService geocode)
  #
  # eg. 123 Elm St, Mystery, Alaska, USA
  #
  # This class is used to determine if a query is a
  # :geocode, how to convert to :geocode
  #
  class Query::Format::Geocode < Query::Format
    def self.is?(query); true; end
  end
end

Barometer::Query.register(:geocode, Barometer::Query::Format::Geocode)
