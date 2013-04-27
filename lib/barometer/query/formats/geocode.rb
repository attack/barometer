module Barometer
  module Query
    module Format
      #
      # eg. 123 Elm St, Mystery, Alaska, USA
      #
      class Geocode < Base
        def self.is?(query); true; end
      end
    end
  end
end

Barometer::Query::Format.register(:geocode, Barometer::Query::Format::Geocode)
