module Barometer
  #
  # eg. 123.1234,-123.123
  #
  class Query::Format::Coordinates < Query::Format
    def self.regex; /^[-]?[0-9\.]+[,]{1}\s?[-]?[0-9\.]+$/; end
  end
end

Barometer::Formats.register(:coordinates, Barometer::Query::Format::Coordinates)
