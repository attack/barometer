module Barometer
  #
  # Format: Zip Code
  #
  # eg. 90210 or 90210-5555
  #
  # This class is used to determine if a query is a
  # :zip_code, how to convert to a :zip_code
  # and what the country_code is.
  #
  class Query::Format::Zipcode < Query::Format
    def self.format; :zipcode; end
    def self.country_code(query=nil); "US"; end
    def self.regex; /(^[0-9]{5}$)|(^[0-9]{5}-[0-9]{4}$)/; end
  end
end

Barometer::Query.register(:zipcode, Barometer::Query::Format::Zipcode)
