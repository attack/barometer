module Barometer
  module Query
    module Format
      #
      # eg. 123.1234,-123.123
      #
      class Coordinates < Base
        def self.regex; /^[-]?[0-9\.]+[,]{1}\s?[-]?[0-9\.]+$/; end

        def self.geo(query)
          return unless query

          coordinates = query.split(',')
          {latitude: coordinates[0].to_f, longitude: coordinates[1].to_f}
        end
      end
    end
  end
end

Barometer::Query::Format.register(:coordinates, Barometer::Query::Format::Coordinates)
