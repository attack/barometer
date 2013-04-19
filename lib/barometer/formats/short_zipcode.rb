module Barometer
  #
  # eg. 90210
  #
  class Query::Format::ShortZipcode < Query::Format
    def self.country_code(query); "US"; end
    def self.regex; /(^[0-9]{5}$)/; end
  end
end

Barometer::Formats.register(:short_zipcode, Barometer::Query::Format::ShortZipcode)
