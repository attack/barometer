module Barometer
  module Query
    module Format
      #
      # eg. 90210 or 90210-5555
      #
      class Zipcode < Base
        def self.geo(query); {country_code: 'US'}; end
        def self.regex; /(^[0-9]{5}$)|(^[0-9]{5}-[0-9]{4}$)/; end
      end
    end
  end
end

Barometer::Query::Format.register(:zipcode, Barometer::Query::Format::Zipcode)
