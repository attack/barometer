module Barometer
  module Query
    module Format
      #
      # eg. 123 Elm St, Mystery, Alaska, USA
      # - this format cannot be detected, only set by explictly
      #
      class Geocode < Base
        def self.is?(query); false; end
      end
    end
  end
end

Barometer::Query::Format.register(:geocode, Barometer::Query::Format::Geocode)
