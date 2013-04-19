module Barometer
  #
  # eg. 90210 or 90210-5555
  #
  class Query::Format::Zipcode < Query::Format
    def self.country_code(query); "US"; end
    def self.regex; /(^[0-9]{5}$)|(^[0-9]{5}-[0-9]{4}$)/; end
  end
end

Barometer::Formats.register(:zipcode, Barometer::Query::Format::Zipcode)
