module Barometer
  #
  # Format: WOEID
  #   "Where on Earth" ID (by Yahoo!)
  #
  # eg. 2459115, 615702 or w90210
  #
  # NOTE: zipcodes and WoeIDs can look exactly the same when the WoeID
  #   is 5 digits long.  For now, a 5 digit number will be detected as
  #   zipcode.  The way to override this is to prepend a number with the
  #   letter 'w'.  Therefore 90210 will be a zipcode and w90210 will be
  #   a WoeID.
  #
  class Query::Format::WoeID < Query::Format

    def self.format; :woe_id; end
    def self.regex; /(^[0-9]{4}$)|(^[0-9]{6,7}$)|(^w[0-9]{4,7}$)/; end
    def self.convertable_formats
      [:short_zipcode, :zipcode, :weather_id, :coordinates, :icao, :geocode, :postalcode]
    end

    # remove the 'w' from applicable queries (only needed for detection)
    #
    def self.convert_query(text)
      return nil unless text
      text.delete('w')
    end

    def self.to(original_query)
      if original_query.format == :weather_id
        converter = Barometer::Converter::FromWeatherIdToGeocode.new(original_query)
        converter.call
      end

      if [:short_zipcode, :zipcode, :icao].include?(original_query.format)
        converter = Barometer::Converter::ToGeocode.new(original_query)
        converter.call
      end

      converter = Barometer::Converter::ToWoeId.new(original_query)
      converter.call

      original_query.get_conversion(:woe_id)
    end

    def self.reverse(query)
      converter = Barometer::Converter::FromWoeIdToGeocode.new(query)
      converter.call
    end
  end
end

Barometer::Query.register(:woe_id, Barometer::Query::Format::WoeID)
