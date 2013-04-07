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

    def self.format; :geocode; end
    def self.is?(query=nil); query.is_a?(String) ? true : false; end
    def self.convertable_formats
      [:short_zipcode, :zipcode, :coordinates, :weather_id, :icao, :woe_id]
    end

    def self.to(query)
      unless converted_query = query.get_conversion(format)
        case query.format
        when :weather_id
          converter = Barometer::Converter::FromWeatherIdToGeocode.new(query)
          converter.call
        when :woe_id
          converter = Barometer::Converter::FromWoeIdToGeocode.new(query)
          converter.call
        else
          converter = Barometer::Converter::ToGeocode.new(query)
          converter.call
        end
      end
    end

    def self.geocode(query)
      converter = Barometer::Converter::ToGeocode.new(query)
      converter.call
    end

  end
end

Barometer::Query.register(:geocode, Barometer::Query::Format::Geocode)
