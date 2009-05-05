module Barometer
  #
  # Postal Code Format
  #
  # eg. 90210
  #
  class Query::ShortZipcode < Query::Format
  
    def self.format; :short_zipcode; end
    def self.country_code(query=nil); "US"; end
    def self.regex; /(^[0-9]{5}$)/; end

  end
end