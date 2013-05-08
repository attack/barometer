module Barometer
  module Query
    module Format
      #
      # Default value
      #
      class Unknown < Base
        def self.is?(query); true; end
      end
    end
  end
end

Barometer::Query::Format.register(:unknown, Barometer::Query::Format::Unknown)
