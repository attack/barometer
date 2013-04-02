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
    def self.convertable_formats; [:short_zipcode]; end

    # convert to this format, X -> :zipcode
    #
    def self.to(original_query)
      raise ArgumentError unless is_a_query?(original_query)
      return nil unless converts?(original_query)
      converted_query = Barometer::Query.new
      converted_query.q = original_query.q
      converted_query.format = format
      converted_query.country_code = country_code(converted_query.q)
      converted_query
    end

  end
end

Barometer::Query.register(:zipcode, Barometer::Query::Format::Zipcode)
