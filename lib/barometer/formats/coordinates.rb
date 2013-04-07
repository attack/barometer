module Barometer
  #
  # Format: Coordinates
  #
  # eg. 123.1234,-123.123
  #
  # This class is used to determine if a query is a
  # :coordinates and how to convert to :coordinates.
  #
  class Query::Format::Coordinates < Query::Format

    def self.format; :coordinates; end
    def self.regex; /^[-]?[0-9\.]+[,]{1}\s?[-]?[0-9\.]+$/; end
    def self.convertable_formats
      [:short_zipcode, :zipcode, :postalcode, :weather_id, :coordinates, :icao, :geocode, :woe_id]
    end

    # convert to this format, X -> :coordinates
    #
    def self.to(query)
      if query.format == :weather_id
        converter = Barometer::Converter::FromWeatherIdToGeocode.new(query)
        converter.call
      end

      if query.format == :woe_id
        converter = Barometer::Converter::FromWoeIdToGeocode.new(query)
        converter.call
      end

      converter = Barometer::Converter::ToCoordinates.new(query)
      converter.call
      query.get_conversion(:coordinates)
    end

    def self.parse_latitude(query)
      coordinates = query.to_s.split(',')
      coordinates ? coordinates[0] : nil
    end

    def self.parse_longitude(query)
      coordinates = query.to_s.split(',')
      coordinates ? coordinates[1] : nil
    end

  end
end

Barometer::Query.register(:coordinates, Barometer::Query::Format::Coordinates)
