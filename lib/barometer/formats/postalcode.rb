module Barometer
  #
  # Format: Postal Code
  #
  # eg. H0H 0H0
  #
  # This class is used to determine if a query is a
  # :postalcode and what the country_code is.
  #
  class Query::Format::Postalcode < Query::Format
  
    def self.format; :postalcode; end
    def self.country_code(query=nil); "CA"; end
    def self.regex
      # Rules: no D, F, I, O, Q, or U anywhere
      # Basic validation: ^[ABCEGHJ-NPRSTVXY]{1}[0-9]{1}[ABCEGHJ-NPRSTV-Z]{1}
      #   [ ]?[0-9]{1}[ABCEGHJ-NPRSTV-Z]{1}[0-9]{1}$
      /^[A-Z]{1}[\d]{1}[A-Z]{1}[ ]?[\d]{1}[A-Z]{1}[\d]{1}$/
    end
  
  end
end