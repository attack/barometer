module Barometer
  #
  # Format: Zip Code (short)
  #
  # eg. 90210
  #
  # This class is used to determine if a query is a
  # :short_zipcode and what the country_code is.
  #
  class Query::Format::ShortZipcode < Query::Format
    def self.country_code(query=nil); "US"; end
    def self.regex; /(^[0-9]{5}$)/; end
  end
end

Barometer::Formats.register(:short_zipcode, Barometer::Query::Format::ShortZipcode)
