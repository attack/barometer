module Barometer
  #
  # Zip Code Format
  #
  # eg. 90210 or 90210-5555
  #
  class Query::Zipcode < Query::Format
  
    def self.regex
      /(^[0-9]{5}$)|(^[0-9]{5}-[0-9]{4}$)/
    end
  
    def self.format
      :zipcode
    end
  
    def self.country_code(query=nil)
      "US"
    end

    # convert to this format
    # accepts :short_zipcode
    def self.to(current_query, current_format)
      current_format == :short_zipcode ? current_query : nil
    end
  
  end
end